package net.vdombox.ide.common
{
	import org.puremvc.as3.multicore.utilities.pipes.interfaces.IPipeFitting;

	public interface IPipe
	{
		function acceptInputPipe( name : String, pipe : IPipeFitting ) : Boolean;
		function acceptOutputPipe( name : String, pipe : IPipeFitting ) : Boolean;
	}
}