package net.vdombox.editors.parsers.base
{

	public class BlockPosition
	{
		public var start : int;

		public var end : int;

		public var otstyp : Object;

		public function BlockPosition( start : int = 0, end : int = 0 )
		{
			this.start = start;
			this.end = end;
		}
	}
}
