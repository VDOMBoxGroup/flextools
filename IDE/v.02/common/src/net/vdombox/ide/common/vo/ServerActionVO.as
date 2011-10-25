package net.vdombox.ide.common.vo
{
	import mx.utils.StringUtil;
	
	/**
	 * The ServerActionVO is Visual Object of VDOM Server Action.
	 * ServerActionVO is contained in VDOM Application. 
	 */
	public class ServerActionVO
	{
		private const TO_XML_TMPL : String =
			"<Action Name=\"{0}\" Language=\"{1}\" Top=\"{2}\" Left=\"{3}\" State=\"{4}\"><![CDATA[{5}]\]></Action>";

		[Bindable]
		public var top : int = 0;

		[Bindable]
		public var left : int = 0;

		[Bindable]
		public var state : Boolean = true;

		[Bindable]
		public var script : String = "";

		[Bindable]
		public var language : String = "";

		private var _name : String = "";

		private var _id : String = "";

		private var _objectID : String;
		private var _objectName : String;

		private var _containerID : String;
		
		private var _visibleEvent : Boolean = true;

		public function get visibleEvent():Boolean
		{
			return _visibleEvent;
		}

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

		public function get objectName() : String
		{
			return _objectName;
		}
		
		public function get containerID() : String
		{
			return _containerID;
		}

		public function set visibleEvent( value : Boolean ) : void
		{
			_visibleEvent = value;
		}
		
		public function setID( value : String ) : void
		{
			_id = value;
		}

		public function setName( value : String ) : void
		{
			_name = value;
		}

		public function setObjectID( value : String ) : void
		{
			_objectID = value;
		}

		public function setObjectName( value : String ) : void
		{
			_objectName = value;
		}
		
		public function setContainerID( value : String ) : void
		{
			_containerID = value;
		}

		// TODO: Во всех VO изменить метод setDescription на setProperties.
		// TODO: Сделать проверку всех properties на наличие, чтобы при отсутствии не падало.
		public function setProperties( propertiesXML : XML ) : void
		{
			var testValue : String;

			testValue = propertiesXML.@ID[ 0 ];

			if ( testValue !== null )
				_id = testValue;

			testValue = propertiesXML.@Name[ 0 ];

			if ( testValue !== null )
				_name = testValue;
			
			testValue = propertiesXML.@Language[ 0 ];
			
			if ( testValue !== null )
				language = testValue;

			testValue = propertiesXML.@Top[ 0 ];

			if ( testValue !== null )
				top = int( testValue );

			testValue = propertiesXML.@Left[ 0 ];

			if ( testValue !== null )
				left = int( testValue );

			testValue = propertiesXML.@State[ 0 ];

			if ( testValue !== null )
				state = testValue == "true" ? true : false;

			testValue = propertiesXML.@ContainerID[ 0 ];

			if ( testValue !== null )
				_containerID = testValue;

			testValue = propertiesXML.@ObjectID[ 0 ];

			if ( testValue !== null )
				_objectID = testValue;

			testValue = propertiesXML.@ObjectName[ 0 ];
			
			if ( testValue !== null )
				_objectName = testValue;

			
			script = propertiesXML[ 0 ];
		}

		public function copy() : ServerActionVO
		{
			var copy : ServerActionVO = new ServerActionVO();

			copy.setID( _id );
			copy.setName( _name );
			
			copy.setObjectID( _objectID );
			copy.setObjectName( _objectName );
			copy.setContainerID( _containerID );

			return copy;
		}

		public function toXML() : XML
		{
			var result : XML;
			var xmlCharRegExp : RegExp = /[<>&"]+/;
			var value : String = script;

			if ( value.search( xmlCharRegExp ) != -1 )
			{
				value = value.replace( /\]\]>/g, "]]]]" + "><![CDATA[>" );
				value = StringUtil.substitute( TO_XML_TMPL, _name, language, top, left, state, value );

				result = new XML( value );
			}
			else
			{
				result = <Action Name={ _name } ObjectID={_objectID} Language={ language } Top={top} Left={left} State={state}>{script}</Action>;
			}

			if( _id && _id != "" )
				result.@ID = _id;
			
			return result;
		}
	}
}