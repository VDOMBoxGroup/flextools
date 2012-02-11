
import memorphic.xpath.XPathQuery;

/**
 * Created by IntelliJ IDEA.
 * User: andreev ap
 * Date: 08.12.11
 * Time: 11:33
 */


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




