package model
{
	import flash.net.SharedObject;

	public class ContactVO
	{
		public var guid : String;
		public var prefix_name : String;
		public var firstName : String;
		public var middle_name : String;
		public var lastName : String;
		public var suffix_name : String;
		public var birthday : String;
		public var company : String;
		public var position : String;
		public var pictureUrl : String;
		public var picture_data : String;
		public var note : String;
		public var owner_guid : String;
		public var contact_lists : String;
		public var fullName : String;
		public var imgGUID : String;
		public var imgURL : String;
		public var image : String; 
		public var label : String;
		
		
		private var sharedObject :SharedObject = SharedObject.getLocal("loginData");
		
		public function ContactVO( object : Object )
		{
			validate( object );	
		}
		
		private function validate( value : Object ):void
		{
			birthday = value["birthday"];
			company = value["company"];
			contact_lists = value["contact_lists"];
			guid = value["guid"];
			firstName = value["first_name"];
			lastName = value["last_name"];
			middle_name = value["middle_name"];
			note = value["note"];
			owner_guid = value["owner_guid"];
			prefix_name = value["prefix_name"];
			position = value["position"];
			pictureUrl = value["picture_url"];
			picture_data = value["picture_data"];
			suffix_name = value["suffix_name"];
			
			image = "http://"+ getSharedObjectData( "server" ) + value["picture_url"]
				trace(image);
			imgGUID = getImgGUID( image );
			imgURL = "app-storage:"  + imgGUID;
		
			
			fullName = lastName + " " + firstName;
			label = fullName +"\n" + birthday;
		}
		
		private function getImgGUID( value : String ) : String
		{
			var matchRes : Array = value.toUpperCase().match(/[A-F0-9]{8}(?:-[A-F0-9]{4}){3}-[A-F0-9]{12}/);
			 
			return 	matchRes[0] ? matchRes[0] : ""; 
		}
		
		protected function getSharedObjectData(name : String) : String
		{
			return	sharedObject.data[ name ] ? sharedObject.data[name] : ""
		}
		
		
	}
}