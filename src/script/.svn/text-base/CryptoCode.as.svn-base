package script
{
	import flash.display.Sprite;
    import flash.utils.ByteArray;

    import com.hurlant.crypto.symmetric.ICipher;
    import com.hurlant.crypto.symmetric.IVMode;
    import com.hurlant.crypto.symmetric.IMode;
    import com.hurlant.crypto.symmetric.NullPad;
    import com.hurlant.crypto.symmetric.PKCS5;
    import com.hurlant.crypto.symmetric.IPad;
    import com.hurlant.util.Base64;
    import com.hurlant.util.Hex;
    import com.hurlant.crypto.Crypto; 

	public class CryptoCode extends Sprite
	{
		private var type:String='simple-des-ecb';
        private var key:ByteArray;

        public function CryptoCode()
        {
                init();
        }

        private function init():void
        {
                key = Hex.toArray(Hex.fromString('965585ea'));//'965585ea0da3aabe0bd61797a0828347'));//'TESTTEST'));// can only be 8characters long

                //trace(encrypt('TEST TEST'));
                //trace(decrypt(encrypt("TEST TEST")));
        }

        public function encrypt(txt:String = ''):String
        {
                var data:ByteArray = Hex.toArray(Hex.fromString(txt));

                var pad:IPad = new PKCS5;
                var mode:ICipher = Crypto.getCipher(type, key, pad);
                pad.setBlockSize(mode.getBlockSize());
                mode.encrypt(data);
                return Base64.encodeByteArray(data);
        }
        public function decrypt(txt:String = ''):String
        {
                var data:ByteArray = Base64.decodeToByteArray(txt);
                var pad:IPad = new PKCS5;
                var mode:ICipher = Crypto.getCipher(type, key, pad);
                pad.setBlockSize(mode.getBlockSize());
                mode.decrypt(data);
                return Hex.toString(Hex.fromArray(data));
        } 
		
	}
}