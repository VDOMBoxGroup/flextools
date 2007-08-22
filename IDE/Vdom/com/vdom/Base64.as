package com.vdom
{
	public class Base64
	{
		var ascii_chars_array:Array=new Array(
			'A','B','C','D','E','F','G','H','I','J','K','L','M','N',
			'O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b',
			'c','d','e','f','g','h','i','j','k','l','m','n','o','p',
			'q','r','s','t','u','v','w','x','y','z','0','1','2','3',
			'4','5','6','7','8','9','+','/');

		function buildPairs():Object {
			var obj:Object=new Object();
			for (var i:Number=0; i < ascii_chars_array.length; i++) {
				obj[ascii_chars_array[i]]=i;
			}
			return obj;
		}
		var pairs_obj:Object= buildPairs();

		function decodeToBinary(block_arr:Array):ByteArray {
			var block_bytes:ByteArray=new ByteArray();
			var ch1:uint=pairs_obj[block_arr.toString().charAt(0)];
			var ch2:uint=pairs_obj[block_arr.toString().charAt(2)];
			var ch3:uint=pairs_obj[block_arr.toString().charAt(4)];
			var ch4:uint=pairs_obj[block_arr.toString().charAt(6)];
			block_bytes.writeByte(ch1 << 2 | ch2 >> 4);
			if (block_arr.toString().charAt(2) != "=") {block_bytes.writeByte(ch2 << 4 | ch3 >> 2);	}
			if (block_arr.toString().charAt(3) != "=") {block_bytes.writeByte(ch3 << 6 | ch4); }
			return block_bytes;
		}
		
		function decodeString(s:String):ByteArray {
			var base64_str:String=s;
			var base64_bytes:ByteArray=new ByteArray();
			var postion_array:Array=new Array();
			var leng:uint=base64_str.length;
			for (var i:uint=0; i <leng; i++) {
				var char:String=base64_str.charAt(i);
				postion_array.push(char);
				if (postion_array.length == 4) {
					base64_bytes.writeBytes(decodeToBinary(postion_array));
					postion_array=new Array();
				}
			}
			return base64_bytes;
		}
	}
}