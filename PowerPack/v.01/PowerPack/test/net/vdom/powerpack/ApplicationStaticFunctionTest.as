/**
 * Created by IntelliJ IDEA.
 * User: andreev ap
 * Date: 08.12.11
 * Time: 10:32
 */
package net.vdom.powerpack
{

import flexunit.framework.TestCase;

import net.vdombox.powerpack.gen.TemplateLib;

public class ApplicationStaticFunctionTest extends TestCase
{

	private var templateLib : TemplateLib = new TemplateLib();

	public function ApplicationStaticFunctionTest( methodName : String = null )
	{
		super( methodName );
	}

	[Test]
	public function testSetApplicationValue() : void
	{
		var applicationXML : XML = <application>
			<a/>
		</application>;

		var queryStr : String = '/application/a';

		var value : String = <b>alex</b>.toXMLString();
		var value2 : String = "alex";

		var control : XML = <application>
			<a>
				<b>alex</b>
			</a>
		</application>;

		var control2 : XML = <application>
			<a>
				<b>alex</b>
			alex
			</a>
		</application>;

		templateLib.setApplicationValue( applicationXML, queryStr, value );
		assertEquals( control.toString(), applicationXML.toString() );

		templateLib.setApplicationValue( applicationXML, queryStr, value2 );
		assertEquals( control2.toString(), applicationXML.toString() );
	}

	[Test]
	public function testGetApplicationValue() : void
	{
		var applicationXML : XML = <application>
			<a>alex</a>
		</application>;
		var queryStr : String = '/application/a';

		var control : XML = <a>alex</a>;
		var result : String = templateLib.getApplicationValue( applicationXML, queryStr );

		assertEquals( control.toString(), result );
	}
}
}
