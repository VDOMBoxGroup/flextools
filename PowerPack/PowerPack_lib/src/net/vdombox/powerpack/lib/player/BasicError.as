package net.vdombox.powerpack.lib.player
{

import mx.utils.StringUtil;

import net.vdombox.powerpack.lib.player.managers.LanguageManager;

public class BasicError extends Error
{
	public static const FATAL : int = 0;
	public static const WARNING : int = 1;
	protected var messages : XML;
	public var severity : int;
	public var details : String;
	public var target : Object;

	public function BasicError( message : String = "", id : int = 0, words : Array = null )
	{
		var _words : Array = [];
		var _words2 : Array = [];

		if ( words )
		{
			_words = words.concat();
			_words2 = words.concat();
		}

		super( message, id );

		_words.unshift( message );
		this.message = (StringUtil.substitute as Function).apply( null, _words );

		var msg : String = getMessageText( id );

		if ( msg )
		{
			details = message;
			_words2.unshift( msg );
			this.message = (StringUtil.substitute as Function).apply( null, _words2 );
		}
	}

	public function getMessageText( id : int ) : String
	{
		if ( !messages )
			return null;

		var messageLst : XMLList = messages.error.(@code == id);

		if ( messageLst.length() == 0 )
			return null;

		var xml : XML = messageLst[0];
		var retVal : String = null;//LanguageManager.sentences[xml.@ID];

		return (retVal ? retVal : xml.text());
	}

	public function getTitle() : String
	{
		if ( message )
			return LanguageManager.sentences.error + ": " + message;

		return LanguageManager.sentences.error + " #" + errorID;
	}

	public function toString() : String
	{
		return "[" + String( LanguageManager.sentences.error ).toUpperCase() + " #" + errorID + "] " + message +
				(details ? "\n" + LanguageManager.sentences.details + ": " + details : "");
	}
}
}