package net.vdombox.powerpack.lib.player.utils
{

import com.hurlant.crypto.Crypto;
import com.hurlant.crypto.hash.IHash;
import com.hurlant.crypto.symmetric.ICipher;
import com.hurlant.crypto.symmetric.IPad;
import com.hurlant.crypto.symmetric.PKCS5;
import com.hurlant.util.Hex;

import flash.utils.ByteArray;

public final class CryptUtils
{
	private static const KEY : String = '7E1DF14E-0AAC-CAD8-05E1-52B7B6B6944C';

	public static function MD5( data : Object ) : String
	{
		var bytes : ByteArray = dataToBytes( data );
		var hash : IHash = Crypto.getHash( 'md5' );

		bytes = hash.hash( bytes );
		bytes.position = 0;

		return bytes.readUTFBytes( bytes.length );
	}

	public static function hex( value : String ) : String
	{
		return Hex.fromString( value );
	}

	public static function encrypt( data : Object, key : Object = KEY ) : ByteArray
	{
		return crypt( data, key, 'encrypt' );
	}

	public static function decrypt( data : Object, key : Object = KEY ) : ByteArray
	{
		return crypt( data, key, 'decrypt' );
	}

	public static function dataToBytes( data : Object ) : ByteArray
	{
		var bytes : ByteArray = new ByteArray();

		if ( data is ByteArray )
			bytes.writeBytes( data as ByteArray );
		else if ( data is String )
			bytes.writeUTFBytes( data as String );
		else
			bytes.writeUTFBytes( data.toString() );

		return bytes;
	}

	private static function crypt( data : Object, key : Object = KEY, mode : String = 'encrypt' ) : ByteArray
	{
		var _bytes : ByteArray = dataToBytes( data );
		var _key : ByteArray = dataToBytes( key );

		var pad : IPad = new PKCS5;
		var hash : IHash = Crypto.getHash( 'sha256' );
		var cipher : ICipher = Crypto.getCipher( "simple-aes-cbc", hash.hash( _key ), pad );

		pad.setBlockSize( cipher.getBlockSize() );

		switch ( mode.toLowerCase() )
		{
			case 'encrypt':
				cipher.encrypt( _bytes );
				break;
			case 'decrypt':
				cipher.decrypt( _bytes );
				break;
		}

		_bytes.position = 0;

		return _bytes;
	}
}
}