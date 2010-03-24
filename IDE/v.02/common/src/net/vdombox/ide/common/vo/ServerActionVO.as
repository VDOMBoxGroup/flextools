package net.vdombox.ide.common.vo
{
	public class ServerActionVO
	{
		[Bindable]
		public var top : int;
		
		[Bindable]
		public var left : int;
		
		[Bindable]
		public var state : Boolean;

		[Bindable]
		public var script : String;
		
		[Bindable]
		public var language : String;
		
		private var _name : String;
		
		private var _language : String;
		
		private var _id : String;
		
		private var _objectID : String;
		
		private var _containerID : String;
		
		public function get name() : String
		{
			return _name;
		}
		
		public function get id() : String
		{
			return _id;
		}
		
		public function get objectID() : String
		{
			return _objectID;
		}
		
		public function get containerID() : String
		{
			return _containerID;
		}
		
		public function setContainerID( value : String ) : void
		{
			_containerID = value;
		}
		
		public function setObjectID( value : String ) : void
		{
			_objectID = value;
		}
		
		// TODO: Во всех VO изменить метод setDescription на setProperties.
		// TODO: Сделать проверку всех properties на наличие, чтобы при отсутствии не падало.
		public function setProperties( propertiesXML : XML ) : void
		{
			var testValue : String;
			
			testValue = propertiesXML.@ID[ 0 ];
			
			if( testValue !== null )
				_id = testValue;
			
			testValue = propertiesXML.@Name[ 0 ];
			
			if( testValue !== null )
				_name = testValue;
			
			testValue = propertiesXML.@Top[ 0 ];
			
			if( testValue !== null )
				top = int( testValue );
			
			testValue = propertiesXML.@Left[ 0 ];
			
			if( testValue !== null )
				left = int( testValue );
			
			testValue = propertiesXML.@State[ 0 ];
			
			if( testValue !== null )
				state = testValue == "true" ? true : false;
			
			testValue = propertiesXML.@ContainerID[ 0 ];
			
			if( testValue !== null )
				_containerID = testValue;
			
			testValue = propertiesXML.@ObjSrcID[ 0 ];
			
			if( testValue !== null )
				_objectID = testValue;
			
			script = propertiesXML[ 0 ];
		}
		
		public function toXML() : XML
		{
			return <Action ID={ _objectID ? _objectID : "" } Name={ _name } Language={ language } >{script}</Action>;
		}
	}
}