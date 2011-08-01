package net.vdombox.ide.common.vo
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.ByteArray;

	/**
	 * The ResourceVO is Visual Object of VDOM Resource.
	 * ResourceVO is contained in VDOM Application. 
	 */	
	[Bindable]
	public class ResourceVO
	{
		public static const EMPTY : uint = 0;

		public static const UPLOAD_PROGRESS : uint = 1;
		public static const UPLOADED 		: uint = 2;
		public static const UPLOAD_ERROR 	: uint = 3;

		public static const LOAD_PROGRESS 	: uint = 4;
		public static const LOADED 			: uint = 5;
		public static const LOAD_ERROR 		: uint = 6;
		public static const ICON_LOADED		: uint = 7;

		public static const ICON_SIZE		: Number = 42; 
		
		public static const RESOURCE_TEMP	: String = "tempResource";
		public static const RESOURCE_NONE	: String = "noneResource";

		public function ResourceVO( ownerID : String )
		{
			_ownerID = ownerID;
			setStatus( EMPTY );
		}

		private var _ownerID : String;

		private var _id : String;

		private var _useCount : int = -1;

		private var _name : String;

		private var _type : String;

		private var _path : String;

		private var _status : uint;

		private var dispatcher : EventDispatcher = new EventDispatcher();
		
		public var data : ByteArray;
		
		public var icon : ByteArray;
		
		private var _iconID : String;

		public function get ownerID() : String
		{
			return _ownerID;
		}

		public function get id() : String
		{
			return _id;
		}
		
		public function get iconId() : String
		{
			return _iconID;
		}
		
		public function set iconId( value : String ) : void
		{
			_iconID = value;
		}

		public function get useCount() : int
		{
			return _useCount;
		}

		public function get name() : String
		{
			return _name;
		}

		public function set name( value : String ) : void
		{
			_name = value;
		}

		public function get status() : uint
		{
			return _status;
		}
		
		public function set status( value : uint ) : void
		{
			_status = value;
		}
		
		public function get type() : String
		{
			return _type;
		}
		
		public function set type( value : String ) : void
		{
			_type = value;
		}
//
//		[Bindable(event="propertyDataChange")]
//		public function get data() : ByteArray
//		{
//			return _data;
//		}
//		
//		public function set data( value : ByteArray ) : void
//		{
//		}		

		public function get size() : int
		{
			if ( !data )
				return -1;

			data.position = 0;

			return data.bytesAvailable;
		}

		public function get path() : String
		{
			return _path;
		}

		public function setID( value : String ) : void
		{
			_id = value;
		}

		public function setType( value : String ) : void
		{
			_type = value.toLowerCase();
		}

		public function setData( value : ByteArray ) : void
		{
			data = value;
			dispatcher.dispatchEvent( new Event( "propertyDataChange" ) );//not used
		}				
		
		/**
		 * reduces the resource to a size 32 to 32 pixels
		 * 
		 * @param value : ByteArray
		 * 
		 */		
		public function setIcon( value : ByteArray ) : void
		{			
			trace ("[ResourceVO] setIcon");
			icon = value;
			_iconID = id + "_icon";
		}

		public function setPath( value : String ) : void
		{
			_path = value;
		}

		public function setStatus( value : uint ) : void
		{
			status = value;
		}

		public function setXMLDescription( description : XML ) : void
		{
			if ( description.@id[ 0 ] )
				_id = description.@id;

			if ( description.@name[ 0 ] )
				name = description.@name;

			if ( description.@type[ 0 ] )
				_type = description.@type;

			if ( description.@usecount[ 0 ] )
				_useCount = description.@usecount;
		}
		
		public function get isViewable () : Boolean 
		{
			if (!_type) 
				return false;
			
			switch (type.toLowerCase()) 
			{
				case "jpg":					
				case "jpeg":					
				case "png":
				case "gif":
				case "svg":
					return true;
					
				default:
					return false;
			}
		}
		
	}
}