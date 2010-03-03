package net.vdombox.ide.common.interfaces
{
	public interface IExternalManager
	{
		function remoteMethodCall( functionName : String, value : String ) : String
	}
}