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
		templateLib.addEventListener(TemplateLibEvent.RESULT_GETTED, )
		templateLib.loadApplication("ID-ID-ID");
	}
}
}
