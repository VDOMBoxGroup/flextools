package vdom.managers.configClasses
{

import flash.filesystem.File;

import vdom.utils.FileUtils;
	
public dynamic class ConfigXML extends Config
{	
	public function loadXMLConfig( path : String ) : Boolean
	{
		var XMLConfigFile : File = new File( path );
		
		if( !XMLConfigFile.exists )
			return false;
		
		var XMLConfig : XML = FileUtils.readXMLFromFile( XMLConfigFile );
		
		if( !XMLConfig )
			return false;
		
		var data : Object = transformNodeToObject( XMLConfig );
		loadConfig( data );
		
		return true;
	}
	
	private function transformNodeToObject( XMLConfig : XML ) : Object
	{
		var currentOject : Object = {};
		
		var attributesXMLList : XMLList = XMLConfig.attributes();
		var attributeName : String;
		var attribute : XML;
		
		for each( attribute in attributesXMLList )
		{
			attributeName = QName( attribute.name() ).localName;
			currentOject[ attributeName ] = attribute.toString();
		}
		
		var node : XML;
		var nodeName : String;
		var nodeValue : *;
		var childObject : Object;
		
		for each( node in XMLConfig.* )
		{	
			nodeName = QName( node.name() ).localName;
			
			if( node.hasComplexContent() || node.attributes().length() > 0 )
			{
				childObject = transformNodeToObject( node );
				nodeValue = childObject;
			}
			else
			{
				nodeValue = node.toString();
				nodeValue = ( nodeValue == null ) ? "" : nodeValue;
			}
			
			if( currentOject.hasOwnProperty( nodeName ) )
			{
				if( !( currentOject[ nodeName ] is Array ) )
				{
					currentOject[ nodeName ] = [ currentOject[ nodeName ] ];
				}
				
				currentOject[ nodeName ].push( nodeValue );
			}
			else
			{
				currentOject[ nodeName ] = nodeValue;
			}
		}
		
		return currentOject;
	}
}
}