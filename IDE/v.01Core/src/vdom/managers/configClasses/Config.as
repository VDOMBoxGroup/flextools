package vdom.managers.configClasses
{
import flash.utils.Proxy;
import flash.utils.flash_proxy;
import flash.utils.getQualifiedClassName;

import mx.utils.ObjectUtil;

public dynamic class Config extends Proxy implements IConfig
{
	protected var _name : String;
	protected var _data : Object = {};
	protected var propertyList:Array;
	
	protected function loadConfig( object : Object ) : void
	{
		_data = {};
		
		var className : String;
		var propertyName : String;
		var value : *;
		var config : Config;
		
		for ( propertyName in object )
		{	
			value = object[ propertyName ];
			className = getQualifiedClassName( value );
		
			switch ( className )
			{
				case "String" :
				{
					_data[ propertyName ] = value;
					break;
				}
				case "Array" :
				{
					_data[ propertyName ] = parseArray( value );
					break;
				}
				case "Object" :
				{
					config = new Config();
					config.loadConfig( value );
					_data[ propertyName ] = config;
					
					break;
				}
			}
		}
	}
	
	public function getName() : String
	{
		return _name;
	}
	
	public function setName( value : String ) : void
	{
		_name = value;
	}
	
	override flash_proxy function getProperty( name : * ) : *
	{
		if( hasOwnProperty( name.toString() ) )
			return _data[ name.toString() ];
		else
			return null;
	}
	override flash_proxy function setProperty( name : *, value : * ) : void
	{
		name = name.toString();
		var className : String = getQualifiedClassName( value );
		var config : Config;
		
		switch ( className )
		{
			case "String" :
			{
				_data[ name ] = value;
				break;
			}
			case "Array" :
			{
				_data[ name ] = parseArray( value );
				break;
			}
			case "Object" :
			{
				config = new Config();
				config.loadConfig( value );
				_data[ name ] = config;
				break;
			}
		}
	}
	
	override flash_proxy function hasProperty( name : * ) : Boolean
	{
		return( name in _data );
	}
	
	override flash_proxy function nextName( index : int ) : String
    {
        return propertyList[ index -1 ];
    }
    
    /**
     *  @private
     */
    override flash_proxy function nextNameIndex( index : int) : int
    {
        if (index == 0)
        {
            setupPropertyList();
        }
        
        if (index < propertyList.length)
        {
            return index + 1;
        }
        else
        {
            return 0;
        }
    }
    
    /**
     *  @private
     */
    override flash_proxy function nextValue( index : int ) : *
    {
        return _data[ propertyList[ index - 1 ] ];
    }
    
    protected function setupPropertyList():void
    {
        if ( getQualifiedClassName( _data ) == "Object" )
        {
            propertyList = [];
            for ( var prop : String in _data )
                propertyList.push( prop );
        }
        else
        {
            propertyList = ObjectUtil.getClassInfo( _data, null, { includeReadOnly : true, uris : [ "*" ] } ).properties;
        }
    }
    
    private function parseArray( array : Array ) : Array
    {
    	var length : uint = array.length;
    	var newArray : Array = [];
    	var className : String;
    	var value : *;
    	var config : Config;
    	
    	for ( var i : uint = 0; i < length; i++ )
    	{
    		value = array[ i ];
			className = getQualifiedClassName( value );
			
			switch ( className )
			{
				case "String" :
				{
					newArray.push( value );
					break;
				}
				case "Array" :
				{
					newArray.push( parseArray( value as Array ) );
					break;
				}
				case "Object" :
				{
					config = new Config();
					config.loadConfig( value );
					newArray.push( config );
					break;
				}
			}
    	}
    	
    	return newArray;
    }
}
}