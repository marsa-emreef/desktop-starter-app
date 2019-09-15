// Modules to control application life and create native browser window
const {app, BrowserWindow} = require('electron');
const path = require('path');
const express = require('express')();
const multer = require('multer');
const bodyParser = require('body-parser');
const fs = require('fs');
const net = require('net');
const http = require('http');
const unzip = require('unzip');
const CryptoJS = require('crypto-js');
const KEY = 'esnaadm';
const PORT1 = 3000;
const PORT2 = 3001;
const encryptDb = false; // for production we set the encryptDB flag to true

express.use(bodyParser.json({limit: '999mb'}));

let mainWindow;

const dbParentFolder = path.join('c:\\', 'Users', 'Public', 'AppData', 'Local', 'esm');
const dbFolder = path.join(dbParentFolder, 'active');
const dbFile = path.join(dbFolder, 'esm.dll');
const distFolder = path.join(dbParentFolder, 'dist');
const downloadFolder = path.join(dbParentFolder, 'download');
const appFolder = path.join(dbParentFolder);

const padding = (pattern, text) => pattern.substr(0, pattern.length - text.length) + text;

function ensureDbFolderAvailable() {
    if (!fs.existsSync(dbParentFolder)) {
        fs.mkdirSync(dbParentFolder);
    }
    if (!fs.existsSync(dbFolder)) {
        fs.mkdirSync(dbFolder);
    }
    if (!fs.existsSync(distFolder)) {
        fs.mkdirSync(distFolder);
    }
    if (!fs.existsSync(downloadFolder)) {
        fs.mkdirSync(downloadFolder);
    }

}

function saveDb(text) {
    return new Promise(resolve => {
        ensureDbFolderAvailable();
        let encryptedText = encryptDb ? CryptoJS.AES.encrypt(text, KEY) : text;
        fs.writeFile(dbFile, encryptedText, (err) => {
            if (err) {
                resolve({success: false, message: err.message});
                return;
            }
            resolve({success: true});
        });
    });
}

express.post('/saveDb', (req, res) => {
    saveDb(JSON.stringify(req.body)).then(val => res.send(JSON.stringify(val)));
});

express.get('/crossdomain.xml', (req, res) => {
    res.send(`
    <?xml version="1.0"?>
    <!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">
    <cross-domain-policy>
        <site-control permitted-cross-domain-policies="*"/>
        <allow-access-from domain="*" secure="false" />
        <allow-http-request-headers-from domain="*" headers="*"/>
    </cross-domain-policy>
    `);
});

express.post('/encrypt', (req, res) => {
    const value = req.body.value;
    const salt = req.body.salt;
    const saltByteArray = CryptoJS.enc.Hex.parse(salt);
    const key = saltByteArray.clone();
    const iv = saltByteArray.clone();
    const sigBytes = saltByteArray.sigBytes / 2;
    key.words = saltByteArray.words.slice(0, 4);
    iv.words = saltByteArray.words.slice(4, 8);
    key.sigBytes = sigBytes;
    iv.sigBytes = sigBytes;
    const encrypted = CryptoJS.AES.encrypt(value, key, {
        mode: CryptoJS.mode.CBC,
        iv: iv,
        padding: CryptoJS.pad.Pkcs7
    });
    const md5 = CryptoJS.MD5(encrypted.toString());
    res.send(JSON.stringify({
        success: true,
        value: md5.toString()
    }));
});


const lookOrUpdateArraysItem = (items, pathToProperty, lastLoop, data, add) => {
    return items.map(item => {
        if (pathToProperty.indexOf('#') > 0) {
            const keysAndPath = pathToProperty.split('#');
            const key = keysAndPath[0];
            const paths = keysAndPath.slice(1, keysAndPath.length);

            const filteredItemsPos = item[key].filter(i => {
                return paths.reduce((match, path) => {
                    const pathsValue = path.split('=');
                    return match && i[pathsValue[0]] == pathsValue[1];
                }, true);
            }).map(i => item[key].indexOf(i));
            if (lastLoop) {
                if (add) {
                    item[key].push(data);
                } else {
                    filteredItemsPos.forEach(index => {
                        item[key][index] = data;
                    });
                }
            }
            return filteredItemsPos.map(i => item[key][i]);
        }
        if (lastLoop) {
            if (add) {
                item[pathToProperty].push(data);
            } else {
                item[pathToProperty] = data;
            }
        }
        return item[pathToProperty]
    });
};


function saveToCatalog(catalog, paths, data, add) {
    try {
        const result = paths.split('.').reduce((baseItem, path, index, source) => {
            let lastLoop = index === (source.length - 1);
            return lookOrUpdateArraysItem(baseItem, path, lastLoop, data, add).reduce((result, array) => {
                if (Array.isArray(array)) {
                    return result.concat(array);
                }
                result.push(array);
                return result;
            }, []);
        }, [{catalog: catalog}]);
        return {
            success: true,
            result: result
        }
    } catch (err) {
        return {
            success: false,
            result: err.message
        }
    }
}

function queryFromCatalog(catalog, path) {

    const func = new Function('catalog', `
            try{
                const get = (chain,item) => chain.split('.').reduce((res,key) => res[key],item);
                const to = (...args) => (item) => args.reduce((res,arg)=>{ res[arg] = get(arg,item); return res;} ,{});
                const filterBy = (key,value) => (item) => item != null && item[key] != null && item[key].toString() == value;
                const except = (...args) => (item) => to.apply(null,Object.keys(item).filter(key => args.indexOf(key) < 0))(item);
                const flat = (arr) => arr.reduce((res,item) => res.concat(item),[]);
                const by = (field,asc='asc') => (a,b) => (asc == 'asc' ? a[field].localeCompare(b[field]) : b[field].localeCompare(a[field]));
                const toDate = (date) => {const t = (from,length) => parseInt(date.substr(from,length));return new Date(t(0,4), t(5,2) - 1, t(8,2), t(11,2), t(14,2), t(17,2));};
                
                const describe = (item) => 
                    Object.keys(item).reduce((res,prop) => {
                        res[prop] = Array.isArray(item[prop]) ? 'array' : typeof item[prop];
                        return res;
                    },{});
                         
                const output = (${path})(catalog); 
                return {
                    success:true,
                    result:output
                }
            }catch(err){
                return {
                    success:false,
                    result:err.message
                }
            }`);
    return func(catalog);
}

let catalog = null;

function currentTime() {
    const now = new Date();
    return `${now.getFullYear()}${padding('00', (now.getMonth() + 1).toString())}${padding('00', now.getDate().toString())}_${padding('00', now.getHours().toString())}${padding('00', now.getMinutes().toString())}${padding('00', now.getSeconds().toString())}_${padding('000', now.getMilliseconds().toString())}`;
}

function loadCatalog() {
    ensureDbFolderAvailable();
    return new Promise((res, rej) => {
        fs.readFile(dbFile, 'utf-8', (err, data) => {
            if (err) {
                rej(err);
                return;
            }
            let text = encryptDb ? CryptoJS.AES.decrypt(data, KEY).toString(CryptoJS.enc.Utf8) : data;
            res(text);
        });
    });

}

let _catalogLoading = false;
let _resolveCallback = [];

function whenCatalogReady() {
    if (!_catalogLoading) {
        _catalogLoading = true;
        loadCatalog().then((val) => {
            catalog = JSON.parse(val);
            _resolveCallback.forEach(r => r.resolve(catalog));
            _resolveCallback = [];
            _catalogLoading = false;
        }).catch(err => {
            _resolveCallback.forEach(r => r.reject('Unable to load File'));
            _resolveCallback = [];
            _catalogLoading = false;
        })
    }

    return new Promise((resolve, reject) => {
        _resolveCallback.push({resolve, reject});
    });
}

express.post('/query', (req, res) => {
    const path = req.body.query;
    const cache = req.body.cache;
    if (cache != 'CACHE') {
        catalog = null;
    }
    if (catalog) {
        res.send(JSON.stringify(queryFromCatalog(catalog, path)));
    } else {
        //we need to call the
        whenCatalogReady().then(catalog => {
            res.send(JSON.stringify(queryFromCatalog(catalog, path)));
        }).catch(err => {
            res.send(JSON.stringify({success: false, result: err}));
        });
    }
});


express.post('/save', (req, res) => {
    const path = req.body.path;
    const add = req.body.add;
    const data = req.body.data;
    if (catalog) {
        res.send(JSON.stringify(saveToCatalog(catalog, path, data, add)));
    } else {
        loadCatalog().then((val) => {
            catalog = JSON.parse(val);
            res.send(JSON.stringify(saveToCatalog(catalog, path, data, add)));
        })
    }
});

function deleteDb() {
    const dbFolderBackup = path.join(dbParentFolder, currentTime());
    return new Promise(resolve => {
        fs.rename(dbFolder, dbFolderBackup, err => {
            if (err) {
                resolve({success: false, message: err ? err.message : ''});
            }
            resolve({success: true});
        })
    });
}

express.post('/deleteDb', (req, res) => {
    deleteDb().then(val => {
        catalog = null;
        res.send(JSON.stringify(val));
    });
});

express.post('/browser', (req, res) => {
    const func = req.body.func;
    const param = req.body.param;
    mainWindow.webContents.send('browser', {func, param});
    res.send({success: true});
});


express.post('/commit', (req, res) => {
    const catalogString = JSON.stringify(catalog);
    ensureDbFolderAvailable();
    saveDb(catalogString).then(val => {
        res.send(JSON.stringify(val));
    });
});

/**
 * This is for the distribution server
 */
express.get('/distribute', (req, res) => {
    res.sendFile(`${__dirname}/distribute.html`);
});

function getLatestDistFileName() {
    const files = fs.readdirSync(distFolder);
    let highestCtime = 0;
    let highestCtimeFile = null;
    files.forEach(f => {
        const fileCTime = fs.statSync(path.join(distFolder, f)).ctimeMs;
        if (fileCTime > highestCtime) {
            highestCtimeFile = f;
            highestCtime = fileCTime;
        }
    });
    return path.basename(highestCtimeFile);
}

express.get('/distribute/latest', (req, res) => {
    res.send({latestVersion: getLatestDistFileName()});
});

express.get('/distribute/downloadDb', (req, res) => {
    res.sendFile(dbFile);
});

express.get('/shutdown',(req,res)=>{
    try{
        app.quit();
        express.close();
    }catch(err){

    }
});

/**
 *This is for uploading DB
 */

const storageForDb = multer.diskStorage({
    destination: dbFolder,
    filename: function (req, file, cb) {
        cb(null, 'esm.dll');
    }
});

const uploadForDb = multer({
    storage: storageForDb, fileFilter: function (req, file, cb) {
        if (path.extname(file.originalname) !== '.dll') {
            return cb(new Error('Only proper dll allowed'))
        }
        cb(null, true)
    }
});

express.post('/distribute/uploadDb', uploadForDb.single('esm'), (req, res, next) => {
    ensureDbFolderAvailable();
    const file = req.file;
    if (!file) {
        const error = new Error('Please upload a file');
        error.httpStatusCode = 400;
        return next(error)
    }
    res.send(file);
});
/**
 * End of uploading DB
 */

express.get('/distribute/download', (req, res) => {
    let version = req.query.version;
    version = version || getLatestDistFileName();
    res.download(path.join(distFolder, version));
});

const storage = multer.diskStorage({
    destination: distFolder,
    filename: function (req, file, cb) {
        cb(null, `${currentTime()}.zip`);
    }
});

const upload = multer({
    storage: storage, fileFilter: function (req, file, cb) {
        if (path.extname(file.originalname) !== '.zip') {
            return cb(new Error('Only Zip are allowed'))
        }
        cb(null, true)
    }
});

express.post('/distribute', upload.single('esm'), (req, res, next) => {
    ensureDbFolderAvailable();
    const file = req.file;
    if (!file) {
        const error = new Error('Please upload a file');
        error.httpStatusCode = 400;
        return next(error)
    }
    res.send(file);
});
/**
 * End of distribution Server
 */

/**
 * This is the start of pulling latest software from server
 */
express.post('/auto-update', (req, res) => {
    const action = req.body.action;
    const serverAddress = req.body.serverAddress;
    if (action == 'latest-version') {
        console.log('Getting latest version');
        http.get(`${serverAddress}/distribute/latest`, (resp) => {
            let data = '';
            resp.on('data', (chunk) => {
                data += chunk;
            });
            resp.on('end', () => {
                res.send(data);
            });
        }).on("error", (err) => {
            res.send({error: err.message});
        });
    }
    if (action == 'download-latest') {
        const dest = path.join(downloadFolder, 'latest.zip');
        const file = fs.createWriteStream(dest);
        http.get(`${serverAddress}/distribute/download`, (resp) => {
            resp.pipe(file);
            file.on('finish', function () {
                file.close(() => {
                    const unzipExtractor = unzip.Extract({path: `${appFolder}/app/`});
                    fs.createReadStream(dest).pipe(unzipExtractor);

                    unzipExtractor.on('close', () => {
                        res.send({success: true});
                    });
                    unzipExtractor.on('error', (err) => {
                        res.send({success: false, message: err.message});
                    });
                });
            });
        }).on("error", (err) => {
            fs.unlink(dest);
            res.send({success: false, message: err.message});
        });
    }
});

/**
 * This is the end of pulling latest software from server
 */

function copyFileSync(source,target){
    let targetFile = target;
    if(fs.existsSync(target)){
        if(fs.lstatSync(target).isDirectory()){
            targetFile = path.join(target,path.basename(source));
        }
    }
    fs.writeFileSync(targetFile,fs.readFileSync(source));
}

function copyFolderRecursivelySync(source,target){
    let files = [];
    const targetFolder = path.join(target,path.basename(source));
    if(!fs.existsSync(targetFolder)){
        fs.mkdirSync(targetFolder);
    }
    if(fs.lstatSync(source).isDirectory()){
        files = fs.readdirSync(source);
        files.forEach((file)=>{
            let curSource = path.join(source,file);
            if(fs.lstatSync(curSource).isDirectory()){
                copyFolderRecursivelySync(curSource,targetFolder);
            }else{
                copyFileSync(curSource,targetFolder);
            }
        })
    }
}
function runApp(port) {
    // check if the download folder has the copy of the flashfiles if not then share it

    if(!fs.existsSync(appFolder)){
        fs.mkdirSync(appFolder);
    }

    if(!fs.existsSync(path.join(appFolder,'app','esnaadm.swf'))){
        const runningOnElectron = __dirname.includes('.asar');
        const sourceDir = (runningOnElectron ? process.resourcesPath : path.join(__dirname, 'dist', 'win-unpacked', 'resources'));
        const sourceFolderToCopy = path.join(sourceDir,'app');
        copyFolderRecursivelySync(sourceFolderToCopy,appFolder);
    }

    // lets check if the target account does not have the copy files then we need to upgrade them
    let pluginName;
    if (process.platform === 'win32') {
        if (process.env.PROCESSOR_ARCHITECTURE == 'AMD64') {
            pluginName = 'pepflashplayer-64.dll';
        } else {
            pluginName = 'pepflashplayer-32.dll';
        }
    } else if (process.platform === 'darwin') {
        pluginName = 'PepperFlashPlayer.plugin';
    } else if (process.platform === 'linux') {
        pluginName = 'libpepflashplayer.so';
    }

    if (app) {
        app.commandLine.appendSwitch('ppapi-flash-path', path.join((__dirname.includes('.asar') ? process.resourcesPath : __dirname), pluginName));
        app.commandLine.appendSwitch('js-flags', "--max-old-space-size=4192");

        const createWindow = () => {
            // Create the browser window.
            mainWindow = new BrowserWindow({
                width: 800,
                height: 600,
                webPreferences: {
                    nodeIntegration: true
                },
                frame: false
            });
            mainWindow.serverPort = port;
            mainWindow.extraResourceDir = appFolder;
            mainWindow.loadFile(`./index.html`);
            mainWindow.on('closed', function () {
                mainWindow = null
            });
        };
        app.on('ready', function(){
            createWindow();
        });
        app.on('window-all-closed', function () {
            if (process.platform !== 'darwin') {
                app.quit();
            }
        });

        app.on('activate', function () {
            if (mainWindow === null) {
                createWindow();
            }
        });

        app.on('certificate-error', function (event, webContents, url, error, certificate, callback) {
            event.preventDefault();
            callback(true);
        });
    }else{
        console.log("Sorry app is empty");
    }
};


function shutdownAnyOpenInstance(port){
    http.get(`http://localhost:${port}/shutdown`, (resp) => {
        console.log(`port ${port} closed`);
    }).on("error", (err) => {
        console.log(`port ${port} closed`);
    });
}

function startEsnaadM(port) {
    const server = net.createServer();
    server.once('error', err => {
        if (err.code == 'EADDRINUSE') {
            shutdownAnyOpenInstance(port);
            startEsnaadM(port == PORT1 ? PORT2 : PORT1);
        }
    });
    server.once('listening', () => {
        if(port == PORT1){
            shutdownAnyOpenInstance(PORT2);
        }
        server.close();
        express.listen(port, () => runApp(port));
    });
    server.listen(port);
};

startEsnaadM(PORT1);

