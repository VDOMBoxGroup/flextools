//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package model
{
	import flash.net.SharedObject;
	public class ContactVO
	{

		public function ContactVO( object : Object )
		{
			validate( object );
		}

		public var birthday : String;

		public var company : String;

		public var contactLists : String;

		public var firstName : String;

		public var fullName : String;
		public var guid : String;

		public var image : String;

		public var imgGUID : String;

		public var imgURL : String;

		public var label : String;

		public var lastName : String;

		public var middleName : String;

		public var note : String;

		public var ownerGuid : String;

		public var pictureUrl : String;

		public var picture_data : String;

		public var position : String;

		public var prefixName : String;

		public var suffixName : String;


		private var sharedObject : SharedObject = SharedObject.getLocal( "loginData" );

		protected function getSharedObjectData( name : String ) : String
		{
			return sharedObject.data[ name ] ? sharedObject.data[ name ] : ""
		}

		private function getImgGUID( value : String ) : String
		{
			var matchRes : Array = value.toUpperCase().match( /[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-F0-9]{12}/ );

			return matchRes[ 0 ] ? matchRes[ 0 ] : "";
		}

		private function validate( value : Object ) : void
		{
			birthday = value[ "birthday" ];
			company = value[ "company" ];
			contactLists = value[ "contact_lists" ];
			guid = value[ "guid" ];
			firstName = value[ "first_name" ];
			lastName = value[ "last_name" ];
			middleName = value[ "middle_name" ];
			note = value[ "note" ];
			ownerGuid = value[ "owner_guid" ];
			prefixName = value[ "prefix_name" ];
			position = value[ "position" ];
			pictureUrl = value[ "picture_url" ];
			picture_data = value[ "picture_data" ];
			suffixName = value[ "suffix_name" ];

			imgURL = "http://" + getSharedObjectData( "server" ) + value[ "picture_url" ]

			imgGUID = getImgGUID( imgURL );
			image = "app-storage:/cache/" + imgGUID;

			fullName = lastName + " " + firstName;
			label = fullName + "\n" + birthday;
		}
	}
}