import memorphic.xpath.XPathQuery;

/**
 * Created by IntelliJ IDEA.
 * User: andreev ap
 * Date: 08.12.11
 * Time: 11:33
 */
public function getApplicationValue(applicationXML : XML, queryStr :String  ) : String
{
	if ( !applicationXML )
	    return "";

	queryStr =   queryStr ? queryStr : "/";

	var myQuery : XPathQuery =  new XPathQuery(queryStr);
	var result : XMLList  =  myQuery.exec( applicationXML );

	return result.toString();
}

public function setApplicationValue(applicationXML : XML, queryStr :String, value : String  ) : String
{
	if ( !applicationXML )
	    return "";

	queryStr =   queryStr ? queryStr : "/";

	var myQuery : XPathQuery =  new XPathQuery(queryStr);
	var result : XMLList  =  myQuery.exec( applicationXML );

	return result.toString();
}
