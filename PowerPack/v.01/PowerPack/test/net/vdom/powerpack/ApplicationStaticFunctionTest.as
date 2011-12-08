/**
 * Created by IntelliJ IDEA.
 * User: andreev ap
 * Date: 08.12.11
 * Time: 10:32
 */
package net.vdom.powerpack {

	import flexunit.framework.TestCase;

	import net.vdombox.powerpack.com.gen.TemplateLib;

	public class ApplicationStaticFunctionTest  extends TestCase {

		private var  templateLib : TemplateLib = new TemplateLib();

		public function ApplicationStaticFunctionTest(methodName:String=null)
		{
			super(methodName);
		}

		[Test]
		public function testSetApplicationValue() : void
		{
			var applicationXML : XML = <application/>;
			var queryStr : String = '';
			var value : String = '';

			templateLib.setApplicationValue(applicationXML, queryStr, value);

			assertEquals(1, 1);
		}

		[Test]
		public function testGetApplicationValue () : void
		{
			var applicationXML : XML = <application><a>alex</a></application>;
			var queryStr : String = '/application/a';

			var control : XML  = <a>alex</a>;
			var result : String = templateLib.getApplicationValue(applicationXML, queryStr);

			assertEquals(control.toString(), result);
		}
	}
}
