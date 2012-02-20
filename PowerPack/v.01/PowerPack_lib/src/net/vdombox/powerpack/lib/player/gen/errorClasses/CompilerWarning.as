package net.vdombox.powerpack.lib.player.gen.errorClasses
{

import net.vdombox.powerpack.lib.player.BasicError;

public class CompilerWarning extends BasicError
{
	public function CompilerWarning( message : String = "", id : int = 0 )
	{
		super( message, id );
		severity = WARNING;
	}

}
}