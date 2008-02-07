package PowerPack.com.mdm
{
	public class MDMError extends Error
	{
		private static const ERR_MSGS:Array = [	"MDM is not initialised",
												"Application object is null" ];
		
		public function MDMError(message:String="", id:int=0)
		{
			if(!message && id>=0 && id<ERR_MSGS.length)
			{
				message = ERR_MSGS[id];
			}
			
			if(!message) message = "";
			
			//TODO: implement function
			super(message, id);
		}
		
	}
}