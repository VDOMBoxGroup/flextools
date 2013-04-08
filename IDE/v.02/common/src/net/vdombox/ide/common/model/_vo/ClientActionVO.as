package net.vdombox.ide.common.model._vo
{
	import mx.resources.ResourceManager;
	import mx.utils.UIDUtil;

	import net.vdombox.ide.common.interfaces.IEventBaseVO;

	/**
	 * The ClientActionVO is Visual Object of VDOM Client Action.
	 * ClientAction is contained in VDOM Type (TypeVO).
	 */
	public class ClientActionVO implements IEventBaseVO
	{
		private var _typeID : String;

		private var _top : int;

		private var _left : int;

		private var _state : Boolean = true;

		private var _id : String;

		private var _objectID : String;

		private var _objectName : String;

		private var _name : String;

		private var _help : String;

		private var _parameters : Array = [];

		[Bindable]
		public var used : Boolean = false;

		private var propertyRE : RegExp = /#Lang\((\w+)\)/g;

		public function ClientActionVO( typeID : String )
		{
			_typeID = typeID;
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

		public function get name() : String
		{
			return _name;
		}

		public function get parameters() : Array
		{
			return _parameters;
		}

		[Bindable]
		public function get state() : Boolean
		{
			return _state;
		}

		public function set state( value : Boolean ) : void
		{
			_state = value;
		}

		[Bindable]
		public function get left() : int
		{
			return _left;
		}

		public function set left( value : int ) : void
		{
			_left = value;
		}

		[Bindable]
		public function get top() : int
		{
			return _top;
		}

		public function set top( value : int ) : void
		{
			_top = value;
		}

		public function setID( value : String ) : void
		{
			_id = value;
		}

		public function setObjectID( value : String ) : void
		{
			_objectID = value;
		}

		public function setObjectName( value : String ) : void
		{
			_objectName = value;
		}

		public function setName( value : String ) : void
		{
			_name = value;
		}

		public function setParameters( value : Array ) : void
		{
			_parameters = value;
		}

		public function get help() : String
		{
			var matchResult : Array = String( _help ).match( propertyRE );
			var matchItem : String;
			var phraseID : String;

			var value : String = _help;

			if ( matchResult && matchResult.length > 0 )
			{
				for each ( matchItem in matchResult )
				{
					phraseID = matchItem.substring( 6, matchItem.length - 1 );
					value = value.replace( matchItem, ResourceManager.getInstance().getString( _typeID, phraseID ) );
				}
			}

			return value;
		}

		//TODO: Разобраться с переименованием!
		public function setProperties( propertiesXML : XML ) : void
		{
			var testValue : String;

			testValue = propertiesXML.@ID[ 0 ];

			if ( testValue !== null )
				_id = testValue;

			testValue = propertiesXML.@ObjTgtID[ 0 ];

			if ( testValue !== null )
				_objectID = testValue;

			testValue = propertiesXML.@ObjTgtName[ 0 ];

			if ( testValue !== null )
				_objectName = testValue;

			testValue = propertiesXML.@MethodName[ 0 ];

			if ( testValue !== null )
				_name = testValue;

			testValue = propertiesXML.@Help[ 0 ];

			if ( testValue !== null )
				_help = testValue;

			testValue = propertiesXML.@Top[ 0 ];

			if ( testValue !== null )
				top = int( testValue );

			testValue = propertiesXML.@Left[ 0 ];

			if ( testValue !== null )
				left = int( testValue );

			testValue = propertiesXML.@State[ 0 ];

			if ( testValue !== null )
				state = testValue == "true" ? true : false;

			var parametersXML : XML = propertiesXML.Parameters[ 0 ];
			var parametersXMLList : XMLList
			var parameterXML : XML;

			if ( parametersXML )
				parametersXMLList = parametersXML.Parameter;
			else
				parametersXMLList = propertiesXML.Parameter

			var actionParameterVO : ActionParameterVO;

			if ( parametersXMLList )
			{
				for each ( parameterXML in parametersXMLList )
				{
					actionParameterVO = new ActionParameterVO( _typeID );
					actionParameterVO.properties = parameterXML;

					_parameters.push( actionParameterVO );
				}
			}
		}

		public function copy() : ClientActionVO
		{
			var copy : ClientActionVO = new ClientActionVO( _typeID );

			//TODO: Создавать новый ID или просто копировать старый, если он есть?
			copy.setID( UIDUtil.createUID() );
			copy.setName( _name );

			copy.setObjectID( _objectID );
			copy.setObjectName( _objectName );

			copy.setParameters( copyParametrs().slice() );

			return copy;
		}

		public function clone() : ClientActionVO
		{
			var copy : ClientActionVO = new ClientActionVO( _typeID );

			copy.setID( _id );
			copy.setName( _name );

			copy.setObjectID( _objectID );
			copy.setObjectName( _objectName );

			copy.setParameters( copyParametrs().slice() );

			copy.top = _top;

			copy.left = _left;
			copy.state = _state;

			return copy;
		}

		private function copyParametrs() : Array
		{
			var parametr : ActionParameterVO;
			var newparametrs : Array = new Array();
			for each ( parametr in parameters )
			{
				newparametrs.push( parametr.copy() );
			}
			return newparametrs;
		}

		public function toXML() : XML
		{
			var result : XML = <Action/>;
			var actionParameterVO : ActionParameterVO;

			result.@MethodName = _name;
			result.@ID = _id;
			result.@ObjTgtID = _objectID;
			result.@Top = top;
			result.@Left = left;
			result.@State = state;

			for each ( actionParameterVO in _parameters )
			{
				result.appendChild( actionParameterVO.toXML() );
			}

			return result;
		}
	}
}
