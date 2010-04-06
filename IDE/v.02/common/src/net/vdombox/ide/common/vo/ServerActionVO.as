package net.vdombox.ide.common.vo
{
	import mx.utils.StringUtil;

	import net.vdombox.utils.StringUtils;

	public class ServerActionVO
	{
		private const TO_XML_TMPL : String =
			"<Action ID=\"{0}\" Name=\"{1}\" Language=\"{2}\" Top=\"{3}\" Left=\"{4}\" State=\"{5}\"><![CDATA[{6}]\]></Action>";

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

			testValue = propertiesXML.@ObjSrcID[ 0 ];

			if ( testValue !== null )
				_objectID = testValue;

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
				value = StringUtil.substitute( TO_XML_TMPL, _id, _name, language, top, left, state, value );

				result = new XML( value );
			}
			else
			{
				result = <Action ID={ _id } Name={ _name } Language={ language } Top={top} Left={left} State={state}>{script}</Action>;
			}

			return result;
		}
	}
}