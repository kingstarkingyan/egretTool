package data
{
	import com.as3xls.xls.Cell;
	
	import flash.utils.Dictionary;

	/**
	 * 导出的数据对象
	 * 等待导出的数据应该包含以下数据
	 * 1、表名
	 * 2、需要导出的字段名
	 * 3、所有的数据对象
	 * 服务器端的数据先不进行导出处理
	 * @author yangyu
	 */	
	public class ExportData
	{
		public static const CLASS_F:String = "QWERTYUIOPASDFGHJKLZXCVBNM";
		public static const CLIENT:String = "CLIENT";
		public static const SERVER:String = "SERVER";
		public static const END:String = "END";
		public static const NO:String = "NO";
		/**类名*/		
		public var className:String;
		/**描述文件*/
		public var infos:Array = [];
		/**需要导出的字段名数组,客户端的*/		
		public var args:Array = [];
		/**需要导出的数据对象*/
		public var datas:Array = [];
		/**需要导出的数据类型*/
		public var types:Array = [];
		
		/**
		 * 根据excel数据进行初始化,并对该表的合法性进行检测
		 * @param sheets 
		 */		
		public function ExportData(sheets:Array)
		{
			/*
			* 关于合法性
			*  从遇到类名开始计算
			* 紧接着的三行分别为CLIENT "" SERVER
			* 如果有CLINET数据即说明为有效数据
			*/
			var i:int = 0;
			var str:String = "";
			for(i;i<sheets.length;i++)
			{
				var arr:Array = sheets[i] as Array;
				if(arr&&arr[0]!=null)
				{
					str = arr[0];
					if(str == CLIENT || str == SERVER || str == END || str == NO)//检查合法性
					{
						return;
					}
					else
					{
						//如果类名是合法的
						if(CLASS_F.indexOf(str.charAt(0))!=-1)
						{
							break;
						}
						else
							return;
					}
				}
			}
			//--------------只有在类名是合法的情况下才会继续------------------
			exportFromIndex(i,sheets);
		}
		
		/**
		 * 开始解析数据
		 * 客户端的命名必须与服务端的一致
		 * @param i 表格的起始行,主要是类名以及中文描述
		 * @param sheets 具体需要解析的数据
		 */		
		private function exportFromIndex(i:int,sheets:Array):void
		{
			var j:int = 0;
			for(i;i<sheets.length;i++)
			{
				var arr:Array = sheets[i];//取其中一行数据进行操作
				var cellFont:Cell = arr[0];
				switch(j)
				{
					case 0://类名
						className = cellFont.value;
						break;
					case 1://解析客户端
						if(cellFont.value!=CLIENT)
						{
							className = null;
							return;
						}
						synArgsClient(arr);
						break;
					case 2://数据类型
						synArgsTypes(arr);
						break;
					case 3://解析服务端——服务端的解析先跳过
						break;
					default://数据对象的解析
						if(cellFont.value==NO)
							continue;
						else
							synData(arr);
						if(cellFont.value==END)
							return;
						break;
				}
				j++;
			}
		}
		
		/**
		 * 解析客户端所需要的字段
		 * @param arr
		 */			
		private function synArgsClient(arr:Array):void
		{
			for(var i:int=1;i<arr.length;i++)
			{
				args.push((arr[i] as Cell).value);
			}
		}
		
		/**
		 * 解析数据类型,有数据类型且有字段名称的才是有效的输出
		 * @param arr 
		 */		
		private function synArgsTypes(arr:Array):void
		{
			for(var i:int=1;i<arr.length;i++)
			{
				types.push((arr[i] as Cell).value);
			}
		}
		
		/**
		 * 解析一个对象,当前只解析客户端的数据
		 * @param arr
		 */		
		private function synData(arr:Array):void
		{
			var dd:Object = new Object();
			for(var i:int = 0;i<args.length;i++)
			{
				if(args[i]==null||args[i]=="")
					continue;
				dd[args[i]] =(arr[i+1] as Cell).value;
			}
			datas.push(dd);
		}
		
		/**
		 * 将两个导出对象进行拼装，新的类名不变只对数据进行拼接
		 * 此函数不会创建新的数据对象，但会改变原有的数据类容
		 * @param data
		 */		
		public function contact(expData:ExportData):void
		{
			datas = datas.concat(expData.datas);
		}
		
		/**
		 * 获取一个完整的JSON格式
		 * @return
		 */		
		public function getTotalJson():String
		{
			var obj:Object = new Object();
			obj.name = className;
			obj.content = datas;
			return JSON.stringify(obj);
		}
		
		/**
		 * 获取ts类
		 * @return
		 */		
		public function getEgretClassCode():String
		{
			var str:String = 
				"{"+
				"\n    /**"+
				"\n     * "+className+
				"\n     * @author ResEncryption_nodep"+
				"\n     */"+
				"\n    class "+className+"LO"+
				"\n    {\n";
			//拼装属性
			for(var i:int=0;i<args.length;i++)
			{
				var key:String = args[i];
				if(key!=null&&key!="")
				{
					str+="        public "+key+":";
					switch(types[i])
					{
						case "int":
						case "Int":
							str += "number;\n";
							break;
						case "string":
						case "String":
							str += "string;\n";
							break;
						case "double":
						case "Double":
							str += "number;\n";
							break;
					}
				}
			}
			//拼装结尾
			str+="    }\n}\n"
			return str;
		}
		
		/**
		 * 获取AS3类
		 * @return
		 */		
		public function getAsClassCode(pcg:String):String
		{
			var str:String = "package "+pcg+
				"\n{"+
				"\n    /**"+
				"\n     * "+className+
	 			"\n     * @author ResEncryption"+
	 			"\n     */"+
				"\n    public class "+className+"LO"+
				"\n    {\n";
			//拼装属性
			for(var i:int=0;i<args.length;i++)
			{
				var key:String = args[i];
				if(key!=null&&key!="")
				{
					str+="        public var "+key+":";
					switch(types[i])
					{
						case "int":
						case "Int":
							str += "int;\n";
							break;
						case "string":
						case "String":
							str += "String;\n";
							break;
						case "double":
						case "Double":
							str += "Number;\n";
							break;
					}
				}
			}
			//拼装结尾
			str+="    }\n}\n"
			return str;
		}
	}
}