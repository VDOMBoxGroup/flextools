/**
 * Created by IntelliJ IDEA.
 * User: andreev ap
 * Date: 27.12.11
 * Time: 11:55
 * To change this template use File | Settings | File Templates.
 */
package net.vdom.powerpack {
import flexunit.framework.TestCase;

import net.vdombox.powerpack.gen.TemplateLib;

public class XMLFunctionTest extends TestCase {
    public function XMLFunctionTest(methodName:String = null) {
        super(methodName);
    }


    private var templateLib : TemplateLib = new TemplateLib();



    [Test]
    public function testSetXMLValue():void
    {
        var queryStr : String = '/application/a';

        var startXML : XML  = <application>
            <a>old value</a>
            <a/>
            <b/>
        </application>;

        var control : XML  = <application>
            <a>value</a>
            <a>value</a>
            <b/>
        </application>;

        var result : String = templateLib.setXMLValue( startXML.toString(), queryStr, "value" );

        assertEquals( control.toString(), result );
    }


    [Test]
    public function testGetXMLValue():void
    {
        var queryStr : String = '/application/a';

        var startXML : XML  = <application>
            <a/>
            <a/>
            <b/>
        </application>;

        var control : XMLList  =  new XMLList("<a/> <a/>");

        var result : String = templateLib.getXMLValue( startXML.toString(), queryStr );

        assertEquals( control.toString(), result );
    }

    [Test]
    public function testAddXMLValue():void
    {
        var queryStr : String = '/';

        var startXML : XML  = <application>
            <a/>
            <a/>
            <b/>
        </application>;

        var control : XML  = <application>
            <a/>
            <a/>
            <b/>
        value
        </application>;


        var result : String = templateLib.addXMLValue( startXML.toString(), queryStr, "value" );

        assertEquals( control.toString(), result );
    }

}
}