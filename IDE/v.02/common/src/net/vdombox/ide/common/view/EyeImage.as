package net.vdombox.ide.common.view
{
	import mx.controls.Image;
	
	public class EyeImage extends Image
	{
		[Embed( source = "assets/eye_closed_white.png" )]
		public var EyeClosedWhite : Class;
		
		[Embed( source = "assets/eye_closed_black.png" )]
		public var EyeClosedBlack : Class;
		
		[Embed( source = "assets/eye_opened.png" )]
		public var EyeOpened : Class;
		
		public static const TYPE_WHITE : String = "white";
		public static const TYPE_BLACK : String = "black";
		
		public var closedEyeType : String = TYPE_BLACK;
		
		
		public function EyeImage()
		{
			super();
			
			open();
		}
		
		public function setOpenState(opened : Boolean):void
		{
			opened ? open() : close();
		}
		
		private function close():void
		{
			switch(closedEyeType)
			{
				case TYPE_BLACK:
				{
					source = EyeClosedBlack;
					break;
				}
				
				case TYPE_WHITE:
				{
					source = EyeClosedWhite;
					break;
				}
					
				default:
				{
					source = EyeClosedBlack;
					break;
				}
			}
			
		}
		
		private function open():void
		{
			source = EyeOpened;
		}
		
		public function remove():void
		{
			source = null;
		}
		
		public function get exists() : Boolean
		{
			return Boolean(source);
		}
		
	}
}