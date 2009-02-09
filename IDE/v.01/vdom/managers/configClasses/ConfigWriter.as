package vdom.managers.configClasses
{
	import flash.filesystem.File;
	
	import vdom.utils.FileUtils;
	
public class ConfigWriter
{
	public function write( fileName : String, config : Config ) : Boolean
	{
		if( !fileName || !config )
			return false;
		
		var XMLConfig : XML = <config />;
		addNode( config, XMLConfig );
		
		var XMLFile : File = new File( fileName );
		
		FileUtils.saveXMLToFile( XMLConfig, XMLFile );
		
		return true;
	}
	
	private function addNode( config : Config, root : XML ) : void
	{
		var nodeName : String;
		var nodeValue : *;
		var node : XML;
		
		for ( nodeName in config )
		{
			nodeValue = config[ nodeName ];
			if( nodeValue == null )
				continue;
			
			if( nodeValue is Config )
			{
				node = < { nodeName } />;
				root.appendChild( node );
				
				var XMLConfigChildren : XMLList = root.*;
				addNode( nodeValue, XMLConfigChildren[ XMLConfigChildren.length() - 1 ] );
			}
			else if( nodeValue is Array )
			{
				insertArray( nodeValue as Array, nodeName, root );
			}
			else
			{
				nodeValue = nodeValue.toString();
				if( String( nodeValue ).search( /\r+|\n+/ ) != -1 )
				{
					node = <{ nodeName }/>;
					node.appendChild( nodeValue );
					root.appendChild( node );
				}
				else
				{
					root[ "@" + nodeName] = nodeValue;
				}
			}
		}
	}
	
	private function insertArray( array : Array, nodeName : String, root : XML ) : void
	{
		var length : uint = array.length;
		var node : XML;
		var value : *; 
		
		for( var i : uint = 0; i < length; i++ )
		{
			value = array[ i ];
			if( value is Config )
			{
				node = < { nodeName } />;
				root.appendChild( node );
				
				var XMLConfigChildren : XMLList = root.*;
				addNode( value, XMLConfigChildren[ XMLConfigChildren.length() - 1 ] );
			}
			else if ( value is Array )
			{
				insertArray( value, nodeName, root );
			}
			else if ( value is String )
			{
				node = <{ nodeName }/>;
				node.appendChild( value.toString() );
				root.appendChild( node );
			}
		}
	}
}
}