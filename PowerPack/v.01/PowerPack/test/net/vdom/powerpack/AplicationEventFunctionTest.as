/**
 * Created by IntelliJ IDEA.
 * User: andreev ap
 * Date: 10.12.11
 * Time: 11:40
 */
package net.vdom.powerpack
{

import flexunit.framework.TestCase;

import net.vdombox.powerpack.events.TemplateLibEvents.TemplateLibEvent;

import net.vdombox.powerpack.gen.TemplateLib;

public class AplicationEventFunctionTest   extends TestCase
{
	public function AplicationEventFunctionTest( methodName : String = null )
	{
		super( methodName );
	}

	private var templateLib : TemplateLib = new TemplateLib();

	[Before]
	public function before(  ) : void
	{

	}

	[Test]
	public function testLoadApplication() : void
	{
		templateLib.addEventListener(TemplateLibEvent.RESULT_GETTED,addAsync(startLoadApplication, 20000)  );
		templateLib.soapBase("login", '192.168.0.18', "root", "root");
	}

	private function startLoadApplication() : void
	{
		templateLib.removeEventListener( TemplateLibEvent.RESULT_GETTED, startLoadApplication );

		templateLib.addEventListener(TemplateLibEvent.RESULT_GETTED, addAsync(resultGettedHandler, 20000) )
		templateLib.loadApplication("8805efe0-2f7f-4b50-b2c4-4883f7f351a8");
	}

	public function resultGettedHandler( event : TemplateLibEvent ) : void
	{

		assertEquals(1, 0);
	}
}
}
