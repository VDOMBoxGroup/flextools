package net.vdombox.powerpack.lib.player.connection.protect
{
	/*
	   1. Вызвав веб-сервис login, ты получаешь две строки: hash string и session key
	   2. Создаешь экземпляр данного класса
	   obj = VDOM_session_protector(hash_str) - hasg string передается
	   конструктору как параметр
	   3. Следующее значение последовательности получаем как:
	   next_key = obj.next_session_key(session_key) - используем полученный
	   session key
	   и далее аналогично, используя предыдущее значение:
	   next_key = obj.next_session_key(next_key)

	   Для теста, чтобы проверить:
	   при
	   hash string:  35156
	   и
	   session key:  5311482591
	   получаем последовательность:
	   Next session:  1357063627
	   Next session:  7719777830
	   Next session:  1550285562
	   Next session:  1010650169
	   Next session:  6027560829
	   Next session:  1211052166
	   Next session:  6427664902
	   Next session:  1291792979
	   Next session:  1058970637
	   Next session:  8122681760
	   Next session:  1629876353
	 */

	import mx.controls.Alert;

	public class VDOMSessionProtector
	{
		//инициализируем обьект закидывая некоторый "хешь"
		public function VDOMSessionProtector( hash_str : String = "" )
		{
			hash = hash_str;
		}

		private var hash : String;

		// закидывая предыдущий sessionKey получаем следующий
		public function nextSessionKey( sessionKey : String = "" ) : String
		{
			var str : String = "";
			var result : Number = 0;
			// пробегаемся по элементо в sessionKey
			for ( var idx : uint = 0; idx < hash.length; idx++ )
			{
				// получаем по элементно все числа в строке
				str = hash.substr( idx, 1 );
				//используя sessionKey и порядковый символ получаем некоторое число
				result += Number( calcHash( sessionKey, Number( str )));
			}
			var hStr : String = "0000000000" + result.toString().substr( 0, 10 );
			
			return hStr.slice( -10, hStr.length ); //возвращаем последние 10 символов
		}

		// алгоритм получения численного хеша.
		private function calcHash( sessionKey : String, val : Number ) : String
		{
			var hStr : String = "";
			var result : String = "";
			
			switch ( val )
			{
				case 1:
				{
					//остаток от деления первых 5-ти чисел на 97
					hStr = "00" + String( Number( sessionKey.substr( 0, 5 )) % 97 )
					//возвращаем последние 2 символа
					result = hStr.slice( -2, hStr.length );
					
					break;
				}
				case 2:
				{
					//строчка sessionKey на оборот
					for ( var i : Number = sessionKey.length; i > 0; --i )
						result += sessionKey.substr( i, 1 );
					
					result += sessionKey.substr( 0, 1 );
					
					break;
				}
				case 3:
				{
					//меняем местами первые 5 символов с последними 5-ю.
					result = sessionKey.slice( -5, sessionKey.length ) + sessionKey.substr( 0, 5 );
					
					break;
				}
				case 4:
				{
					var num : Number = 0;
					// Абра-Кадабра
					for ( i = 1; i < 9; i++ )
						num += Number( sessionKey.charAt( i )) + 41
					
					result = num.toString();
					
					break;
				}
				case 5:
				{
					num = 0;

					// код каждого символа XOR"им  и результат складываем
					for ( i = 0; i < sessionKey.length; i++ )
					{
						hStr = String.fromCharCode( sessionKey.charCodeAt( i ) ^ 43 );
						
						if ( !Number( hStr ))
							hStr = hStr.charCodeAt().toString();

						num += Number( hStr );
					}

					result = num.toString();
					
					break;
				}
				default:
				{
					result = ( Number( sessionKey ) + val ).toString();
					
					break;
				}
			}
			
			return result;
		}
	}
}