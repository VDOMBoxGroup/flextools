import memorphic.xpath.XPathQuery;

/**
 * User: andreev ap
 * Date: 27.12.11
 * Time: 12:07
 */


public function getXMLValue( xml : XML, queryStr : String ) : XMLList
{

    return  getQueryResult(xml, queryStr);
}


public function setXMLValue( xml : XML, path : String, value : Object ) : XML
{
    var queryResult : XMLList = getQueryResult(xml, path) ;

    for each ( var xmlNode : XML in queryResult )
    {
        xmlNode.setChildren( value) ;
    }

    return xml;
}


public function addXMLValue( xml : XML, queryStr : String, value : Object ) : XML
{
    var queryResult : XMLList = getQueryResult(xml, queryStr) ;

    for each ( var xmlNode : XML in queryResult )
    {
        xmlNode.appendChild( value);
    }

    return xml;
}


private function getQueryResult(xml : XML, path:String):XMLList
{
    path = path ? path : "/";

    var xPathQuery:XPathQuery =  new XPathQuery( path );

    return  xPathQuery.exec( xml );
}
