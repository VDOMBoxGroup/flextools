import connection.protect.SOAPApplicationLevel;

import memorphic.xpath.XPathQuery;

/**
 * Created by IntelliJ IDEA.
 * User: andreev ap
 * Date: 08.12.11
 * Time: 11:33
 */
public function getApplicationValue( applicationXML : String, queryStr : String ) : String
{
	var xml : XML;
	try
	{
		xml = new XML(applicationXML);
	}
	catch ( error : Error )
	{
		return "";
	}

	var myQuery : XPathQuery;
	var result : XMLList;

	queryStr = queryStr ? queryStr : "/";
	myQuery = new XPathQuery( queryStr );
	result = myQuery.exec( xml );

	return result.toString();
}

public function setApplicationValue( applicationXML : XML, queryStr : String, value : Object ) : XML
{
	if ( !applicationXML )
		return null;

	queryStr = queryStr ? queryStr : "/";

	var myQuery : XPathQuery = new XPathQuery( queryStr );

	var queryResult : XMLList = myQuery.exec( applicationXML );

	for each ( var xml : XML in queryResult )
	{
		try
		{
			xml.appendChild( new XML( value ) );
		}
		catch ( error : Error )
		{
			xml.appendChild( value );
		}
	}

	applicationXML.normalize();

	return applicationXML;
}

public function loadApplication( applicationID : String ) : Function
{
	var soapApplicationLevel : SOAPApplicationLevel = new SOAPApplicationLevel();

	soapApplicationLevel.addEventListener( SOAPApplicationLevel.RESULT_GETTED, rusulGettedHandler, false, 0, true );
	soapApplicationLevel.addEventListener( SOAPApplicationLevel.ERROR, rusulGettedHandler, false, 0, true );
	soapApplicationLevel.loadApplication( applicationID );

	function rusulGettedHandler( event : Event ) : void
	{
		soapApplicationLevel.removeEventListener( SOAPApplicationLevel.RESULT_GETTED, rusulGettedHandler );
		soapApplicationLevel.removeEventListener( SOAPApplicationLevel.ERROR, rusulGettedHandler );

		if ( event.type == SOAPApplicationLevel.RESULT_GETTED )
		{
			setReturnValue( soapApplicationLevel.result );

		}
		else
		{
			setReturnValue( soapApplicationLevel.errorResult );

		}

	}

	return rusulGettedHandler;
}



