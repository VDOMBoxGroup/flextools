import memorphic.xpath.XPathQuery;

/**
 * User: andreev ap
 * Date: 27.12.11
 * Time: 12:07
 */


public function getXMLValue( xmlString : String, queryStr : String ) : String
{
    var xml : XML = string2xml( xmlString ) ;

    return  getQueryResult(xml, queryStr).toString();
}


public function setXMLValue( xmlString : String, path : String, value : Object ) : String
{
    var xml : XML = string2xml( xmlString ) ;
    var queryResult : XMLList = getQueryResult(xml, path) ;

    for each ( var xmlNode : XML in queryResult )
    {
        xmlNode.setChildren( value) ;
    }

    // todo: is it necessary?
//    xml.normalize();

    return xml.toString();
}


public function addXMLValue( xmlString : String, queryStr : String, value : Object ) : String
{
    var xml : XML = string2xml( xmlString ) ;
    var queryResult : XMLList = getQueryResult(xml, queryStr) ;

    for each ( var xmlNode : XML in queryResult )
    {
        xmlNode.appendChild( value);
    }

    // todo: is it necessary?
//    xml.normalize();

    return xml.toString();
}


private function getQueryResult(xml : XML, path:String):XMLList
{
    path = path ? path : "/";

    var xPathQuery:XPathQuery =  new XPathQuery( path );

    return  xPathQuery.exec( xml );


}


private function string2xml(value : String ):XML
{
    var xml : XML;

    try
    {
        xml = new XML(value);
    }
    catch ( error : Error )
    {
        //TODO: rise Exception

    }

    return xml ||  new XML();
}

