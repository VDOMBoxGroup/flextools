package net.vdombox.ide.model.vo 
{
	public class LoginInformation 
	{
		public var username : String;
		public var password : String;
		public var hostname : String;
		public var serverVersion : String;

		public function Employee(	emp_id : uint =			0, 
									firstname : String =	"", 
									lastname : String =		"", 
									email : String =		"", 
									startdate : Date =		null ) 
		{
			this.emp_id = ( emp_id == 0 ) ?  currentIndex += 1 : emp_id;
			this.firstname = firstname;
			this.lastname = lastname;
			this.email = email;
			this.startdate =  ( startdate == null ) ?  new Date() : startdate;
		}
	}
}