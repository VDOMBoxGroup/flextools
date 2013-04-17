package net.vdombox.object_editor.model.proxy
{
import flash.filesystem.File;
import flash.net.SharedObject;

import org.puremvc.as3.interfaces.IProxy;
import org.puremvc.as3.patterns.proxy.Proxy;

public class LaTexProxy extends Proxy implements IProxy
{
	public static const NAME : String = "LaTexProxy";

	public function LaTexProxy()
	{
		super( NAME );
	}

	private var shObject : SharedObject;

	private var _typesDocPath : String = "";

	public function get typesDocPath() : String
	{
		return _typesDocPath;
	}

	public function set typesDocPath( value : String ) : void
	{
		if ( value == _typesDocPath )
		{
			return;
		}

		_typesDocPath = value;

		shObject.data["types_doc_path"] = value;

		sendNotification( ApplicationFacade.TYPES_DOC_PATH_CHANGED, _typesDocPath );
	}

	override public function onRegister() : void
	{
		super.onRegister();

		shObject = SharedObject.getLocal( "doc_settings" );

		if ( shObject.data.hasOwnProperty( "types_doc_path" ) )
		{
			_typesDocPath = shObject.data["types_doc_path"];
		}

	}

	public function getSectionPaths( laTexContent : String, sectionName : String ) : Array
	{
		var startIndex : int = laTexContent.indexOf( "\input{types/" + sectionName + "}" );
		var attrSection : String = laTexContent.substring( startIndex );

		var relatedPaths : Array = attrSection.split( "\n" );

		if ( !relatedPaths || relatedPaths.length < 1 )
		{
			return null;
		}

		relatedPaths = relatedPaths.slice( 1 );

		var nativePaths : Array = [];
		for each ( var relatedPath : String in relatedPaths )
		{
			if ( !relatedPath )
			{
				break;
			}

			relatedPath = relatedPath.substring( relatedPath.indexOf( "{" ) + 1, relatedPath.indexOf( "}" ) );
			relatedPath = relatedPath.substring( 5 ); // remove "types/" from the beginning

			var nativePath : String = typesDocPath + relatedPath + ".tex";
			nativePath = fileProxy.getCorrectFilePath( nativePath );

			nativePaths.push( nativePath );
		}

		return nativePaths;
	}

	public function getPropertyDescription( laTexContent : String ) : String
	{
		if ( !laTexContent )
			return "";

		var description : String = "";

		var startIndex : int = laTexContent.indexOf( "&" );

		description = laTexContent.substring(startIndex);
		description = description.split("\n")[0];

		description = description.replace("\r", "");

		description = convertBoldText( description );
		description = convertExpression( description, / --- /g, ' - ' );                   // ' --- ' -> ' - '
		description = convertExpression( description, /\\textless[ ]{0,1}/g, '<' );     //  '\textless ' -> '<'
		description = convertExpression( description, /[ ]{0,1}\\textgreater/g, '>' );  //  ' \textgreater' -> '>'
		description = convertExpression( description, /\\#/g, '#' );                       // '\#' -> '#'
		description = convertExpression( description, /\\_/g, "_" );                       // '\_' -> '_'

		description = convertExpression( description, /^[ ]*&[ ]*$\n/mg, '' );
		description = convertExpression( description, /^[ ]*&[ ]*/mg, '' );

		description = convertExpression( description, /^%.*$\n/mg, '' );                      // '%Text\n' -> ''
		description = convertExpression( description, /%.*$/mg, '' );                      // 'Text %Comment' -> 'Text'


		return description;
	}

	public function getAttributeName( laTexContent : String ) : String
	{
		var attrName : String = "";

		if ( !laTexContent )
			return attrName;

		var texParagraphs : Array = laTexContent.split( "\n" );

		if ( !texParagraphs || texParagraphs.length < 1 )
			return attrName;

		var texParagraph : String = "";
		var paragraphIsName : Boolean = false;

		for ( var i : int = texParagraphs.length-1; i >= 0 ; i-- )
		{
			texParagraph = texParagraphs[i];

			if (!texParagraph)
				continue;

			if (paragraphIsName)
			{
				attrName = texParagraph.replace("\r", "");
				break;
			}

			if ( texParagraph.indexOf("\\\\\\hline") >= 0 )
				paragraphIsName = true;

		}

		attrName = convertExpression( attrName, /^[ ]*&[ ]*$\n/mg, '' );
		attrName = convertExpression( attrName, /^[ ]*&[ ]*/mg, '' );

		attrName = convertExpression( attrName, /\\#/g, '#' );                       // '\#' -> '#'
		attrName = convertExpression( attrName, /\\_/g, "_" );                       // '\_' -> '_'
		attrName = convertExpression( attrName, /^%.*$\n/mg, '' );                      // '%Text\n' -> ''
		attrName = convertExpression( attrName, /%.*$/mg, '' );                      // 'Text %Comment' -> 'Text'

		return attrName;
	}

	public function getEventName( laTexContent : String ) : String
	{
		var eventName : String = "";

		if ( !laTexContent )
			return eventName;

		var texParagraphs : Array = laTexContent.split( "\n" );

		if ( !texParagraphs || texParagraphs.length < 1 )
			return eventName;

		for each ( var texParagraph : String in texParagraphs )
		{
			texParagraph = convertExpression( texParagraph, /^%.*$\n/mg, '' );                   // '%Text\n' -> ''
			texParagraph = convertExpression( texParagraph, /%.*$/mg, '' );                      // 'Text %Comment' -> 'Text'

			if ( !texParagraph )
				continue;

			eventName = texParagraph.replace("\r", "");
			eventName = convertExpression( eventName, /\\#/g, '#' );                       // '\#' -> '#'
			eventName = convertExpression( eventName, /\\_/g, "_" );                       // '\_' -> '_'
			break;
		}

		return eventName;
	}

	public function getActionName( laTexContent : String ) : String
	{
		return getEventName( laTexContent );
	}

	private function convertBoldText( source : String ) : String
	{
		if ( !source )
		{
			return "";
		}

		var boldCommandRegExp : RegExp = /\\textbf\{[^\{]*\}/g;

		var boldCommands : Array = source.match( boldCommandRegExp );

		if ( !boldCommands || boldCommands.length < 1 )
		{
			return source;
		}

		var result : String = source;
		for each ( var boldCommand : String in boldCommands )
		{
			var boldTag : String = "'" + boldCommand.substring( 8, boldCommand.length - 1 ) + "'"
			result = result.replace( boldCommand, boldTag );
		}

		return result;
	}

	private function convertExpression( source : String, pattern : RegExp, repl : String ) : String
	{
		if ( !source )
		{
			return "";
		}

		return source.replace( pattern, repl );
	}

	public function isCorrectTypesDocPath( folder_path : String ) : Boolean
	{
		if ( !folder_path )
		{
			return true;
		}

		var docFolderContent : Array = fileProxy.getFolderContent( folder_path );

		if ( !docFolderContent )
		{
			return false;
		}

		var typesFolder : File;
		for each ( var file : File in docFolderContent )
		{
			if ( file.isDirectory && file.exists && file.name == "type" )
			{
				typesFolder = file;
				break;
			}
		}

		if ( !typesFolder )
		{
			return false;
		}

		var typesLaTexFiles : Array = fileProxy.filterLaTexFiles( typesFolder.getDirectoryListing() );

		if ( !typesLaTexFiles || typesLaTexFiles.length < 1 )
		{
			return false;
		}

		return true;
	}

	private function get fileProxy() : FileProxy
	{
		return facade.retrieveProxy( FileProxy.NAME ) as FileProxy;
	}


}
}