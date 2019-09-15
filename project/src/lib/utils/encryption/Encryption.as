package lib.utils.encryption
{
	import flash.utils.ByteArray;
	
	import lib.utils.encryption.crypto.Crypto;
	import lib.utils.encryption.crypto.symmetric.AESKey;
	import lib.utils.encryption.crypto.symmetric.CBCMode;
	import lib.utils.encryption.crypto.symmetric.ICipher;
	import lib.utils.encryption.crypto.symmetric.IPad;
	import lib.utils.encryption.crypto.symmetric.IVMode;
	import lib.utils.encryption.crypto.symmetric.NullPad;
	import lib.utils.encryption.crypto.symmetric.PKCS5;
	import lib.utils.encryption.util.Base64;
	
	import mx.utils.Base64Decoder;

	public class Encryption
	{
		public var time:Number;
		public var data:String;
		
		private var decryptionKeys:Array = [
			"wN/6nM2MnGnKYxPnxzs97Eqf9r6azZIp0E5TA9IP8Vc=", "SuWJ7BKJRJi6Nlta9srEQQ==",
			"IZMzIj6ojv/aV2HPLZh6jSZO+PaW23pJ/mzLvm5VMkA=", "fhNm1BVTvRC6QM2ZJeSx3Q==",
			"KRFhYwTLn8NE8JQ0AbHUshwRMVKiN58st4D9tT4eKTs=", "xZsktnbLaXSr4ZtbS375tg==",
			"YdjXbbP1c8Uyrvd6EqSRkIIRzb6PJuULCOVUgpRjw54=", "1vW3zeV5FzRPcKblbbn6ug==",
			"x3OmZ1qxMGnsCykczS/TzKXUkXZQQV2KpMWFzXCOY3E=", "++/KVr1XV0HfDVSSzzJYvw==",
			"XV+DYLyNXy65F/onA35bJFqsiy7hojBuUG51w+9DET8=", "/RgU47gCd47boCaxKN9MNw==",
			"2GHi8cBG8LFBDFg2LX4AX3V4SqNuguyDZFGQgnx/Kgs=", "ALQfJtXRm72B640HaD05YQ==",
			"x8g418pW+Skbys4EMpbv8NNL/ooafZ8Qpv0Y5N0tb3E=", "JOK+r5y7acLCv39/NzoCzg==",
			"4f1/tgz4eRmj5AumR14lFbcG4EjPCeRiSDkr2vYs5mk=", "OlfomlqkalsfHL33YfYukw==",
			"BQOmmAQN+f2mLy/G+mn2BMBO48eEsTgYthJP86Pb7zQ=", "U0Tky61XJdwTWC3H800XpQ=="
		];
		
		private static const SECRET:String = Math.round(Math.random()*10000000000).toString();
		
		public function Encryption(secret:String='')
		{
			if(secret != SECRET){
				throw new Error('Instantiate this class is not allowed');	
			}
		}
		
		public static function encryptData(data:String):Encryption{
			var encryption:Encryption = new Encryption(SECRET);
			var timeStamp:Number = new Date().time;
			var randomKeyIndex:Number = (timeStamp % 10) * 2;
			var selectedDecryptionKey:String = encryption.decryptionKeys[randomKeyIndex];
			var IV:String = encryption.decryptionKeys[randomKeyIndex+1]
			encryption.time = timeStamp;
			encryption.data = encrypt(data,Base64.decodeToByteArray(selectedDecryptionKey),Base64.decodeToByteArray(IV));  
			return encryption;
		}
		
		public static function decryptData(timeStamp:Number,data:String):String{
			var encryption:Encryption = new Encryption(SECRET);
			var randomKeyIndex:Number = (timeStamp % 10) * 2;
			var selectedDecryptionKey:String = encryption.decryptionKeys[randomKeyIndex];
			var IV:String = encryption.decryptionKeys[randomKeyIndex+1]
			return decrypt(data,Base64.decodeToByteArray(selectedDecryptionKey),Base64.decodeToByteArray(IV));
		}
		
		private static function decrypt(input:String,key:ByteArray,decrIV:ByteArray):String
		{
			var ba:ByteArray = Base64.decodeToByteArray(input);
			var aesKey:AESKey = new AESKey(key);
			var cbcMode:CBCMode = new CBCMode(aesKey,new PKCS5(16));
			cbcMode.IV = decrIV; 
			cbcMode.decrypt(ba);
			ba.position = 0;
			return ba.readUTFBytes(ba.length);
		}
		
		private static function encrypt(input:String,key:ByteArray,decrIV:ByteArray):String
		{
			var ba:ByteArray = new ByteArray();
			ba.writeUTFBytes(input);
			var aesKey:AESKey = new AESKey(key);
			var cbcMode:CBCMode = new CBCMode(aesKey,new PKCS5(16));
			cbcMode.IV = decrIV; 
			cbcMode.encrypt(ba);
			return Base64.encodeByteArray(ba);
		}
		
		public function toString():String{
			var result:String = JSON.stringify({ts : this.time,v : this.data});
			return result;
		}
	}
}