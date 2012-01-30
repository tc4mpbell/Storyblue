package script
{
	//import com.hurlant.util.der.Integer;
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	
	/*
		CRUD for goals and daily word tracking
	*/
	public class GoalsAndWords
	{
		private const MS_PER_DAY:uint = 1000 * 60 * 60 * 24;
		
		private var conn:SQLConnection;
		
		public function GoalsAndWords()
		{
			conn = StoryDB.Open();
			
			//delTables(); //test
			createGoalsTable();
			createWordCountTable();
			
			//testData();//"D6F2CDAF-9F70-F779-5671-505204229B30");
		}
		
		private function delTables():void
		{
			var sql:String = "";
			sql = "DROP TABLE storyblue_wordcount";		
			try
			{	
			StoryDB.Exec(conn, sql);
			}catch(e:Error){}
			sql = "DROP TABLE storyblue_goals";
			StoryDB.Exec(conn, sql);
			
			
		}
		
		private function createGoalsTable():void
		{
			var sql:String = "";
			sql += "CREATE TABLE IF NOT EXISTS storyblue_goals (";
			sql += "	id	INTEGER PRIMARY KEY AUTOINCREMENT,";
			sql += "	story_id		TEXT,";
			sql += "	name			TEXT,";
			sql += "	word_goal		INTEGER,";
			sql += "	period_in_days	INTEGER,";
			sql += "	start_date		DATE,";
			sql += "	end_date		DATE,";
			sql += "	active			INTEGER,";
			sql += "	UNIQUE (name, story_id)";
			sql += ")";
			
			StoryDB.Exec(conn, sql);
		}
		
		private function createWordCountTable():void
		{
			var sql:String = "";
			sql += "CREATE TABLE IF NOT EXISTS storyblue_wordcount (";
			sql += "	id	INTEGER PRIMARY KEY AUTOINCREMENT,";
			sql += "	story_id		TEXT,";
			sql += "	word_count		INTEGER,";
			sql += "	date			DATE,";
			sql += "	UNIQUE (date, story_id)";
			sql += ")";
			
			StoryDB.Exec(conn, sql);
		}
		
		private function testData(storyID:String = "4CA4B7F7-F73D-BD97-45EB-ACF308C782B6"):void
		{
			//for(var i=0; i<31; i++)
			//{
			//	//month is zero indexed.
			//	UpdateDayWords(new Date(2010,3,i), Math.round(Math.random()*1500), storyID);
			//}
			
			var d:Date = new Date();
			d.setDate(d.date - 2);
			
			new Settings().Set("WordCount_" + storyID, "0");
			UpdateDayWords(d, 941, storyID);
		}
		
		
		[Bindable]
		public function AllGoals(storyId:String = ""):Array
		{
			if(storyId == "") storyId = mx.core.Application.application.story.StoryID;
			
			var sql:String = "SELECT * FROM storyblue_goals WHERE story_id = '" + storyId + "'";
			var res:SQLResult = StoryDB.Get(conn, sql);
			
			if(res == null) return null;
			
			for(var i in res.data)
			{
				res.data[i] = GoalWithStatus(res.data[i]);
			}
			
			return res.data;
		}
		
		[Bindable]
		public function GetGoal(goalId:int):Object
		{
			var o:Object = {};
			
			var sql:String = "SELECT * FROM storyblue_goals WHERE id = " + goalId.toString();
			var res:SQLResult = StoryDB.Get(conn, sql);
			
			if(res != null && res.data != null)
			{
				o = res.data[0];
				o = GoalWithStatus(o);
			}
			
			return o;
		}
		
		
		public function GoalWithStatus(o:Object):Object
		{
			var total:int = GetTotalWordsOverDateRange(new Date(Date.parse(o.start_date)), 
     			new Date(), mx.core.Application.application.story.StoryID);
	     	var range:Date = new Date(new Date().valueOf() - new Date(Date.parse(o.start_date)).valueOf());
	     	var days:Number = Math.round((range.time / MS_PER_DAY) + 1);
	     	
	     	var rangeAll:Date = new Date(new Date(Date.parse(o.end_date)).valueOf() - new Date(Date.parse(o.start_date)).valueOf());
	     	var daysAll:Number = Math.round((rangeAll.time / MS_PER_DAY) + 1);
			var totAvePerc:int = 0;
			if(o["end_date"] == null)
			{
				//daily goal
				o.type = "daily";
				
				//set status
				totAvePerc = 100/(o.word_goal / (total/days));
				
				/*//set daily goal
				var dailyGoal:Array = new Array();
				for(var i=0; i<daysAll; i++)
				{
					dailyGoal.push({ Goal: o.word_goal });
				}
				o.goals = dailyGoal;*/
				o.totAve = o.word_goal;//(o.word_goal / (total/days);
			}
			else
			{
				//long-term goal
				//status
				var rgToEnd:Date = new Date(new Date(Date.parse(o["end_date"])).valueOf() - new Date().valueOf());
     			var daysToEnd:Number = Math.round((rgToEnd.time / MS_PER_DAY) + 1);
     			
				var remain:int = parseInt(o.word_goal) - total;
	     		/*var aveToFinish = remain / daysToEnd;
	     		var aveTilNow = total / days;
	     		totAvePerc = (total/parseInt(o.word_goal))*100;//(aveTilNow/aveToFinish)*100;
				*/
				var aveNeedPerDay:int = o.word_goal / daysAll;
				var shouldHaveByNow:int = aveNeedPerDay * days;
				var totTilNow:int = total;
				var percShouldHaveVsActual:int = 100 / (shouldHaveByNow / totTilNow);
				
				totAvePerc = percShouldHaveVsActual;
	     		
				/*if(tilNowPerc < 50) o.status = "RED";
	     		else if(tilNowPerc < 80) o.status = "YELLOW";
	     		else o.status = "GREEN";*/
	     		
	     		//only long-term goals can be complete
	     		if(daysToEnd <= 0 || remain <= 0)//totAvePerc >= 100)
	 			{
	 				o.status = "COMPLETE";
	 				o.statusColor = "0x000000";
	 			}
				
				o.totAve = parseInt(o.word_goal)/daysAll;
			}
			
			o.totAvePerc = totAvePerc;
			
			if(totAvePerc < 50) {
				o.status = "RED";
				o.statusColor = "0xaa2222"
			}
 			else if(totAvePerc < 80) {
 				o.status = "YELLOW";
 				o.statusColor = "0xcccc44"
 			}
 			else if(o.status != "COMPLETE") {
 				o.status = "GREEN";
 				o.statusColor = "0x44cc44"
 			}
 			
			return o;
		}
		
		
		public function DeleteGoal(id:int):void
		{
			var sql:String = "DELETE FROM storyblue_goals WHERE id = " + id;
			StoryDB.Exec(conn, sql);
		}
		
		public function CreateOrUpdateGoal(wordGoal:int, periodInDays:int = -1, endDate:Date = null, goalId:int = -1, startDate:Date = null):void
		{
			var storyID:String = mx.core.Application.application.story.StoryID;
			var goalName:String = "";
			
			if(periodInDays == -1)	//long-term goal
			{
				goalName = "Goal: " + wordGoal + " by "+ Utilities.date(endDate);
			}
			else //daily/weekly goal
			{
				if(periodInDays == 1)
				{
					goalName = "Daily Goal: " + wordGoal; 	
				}
				else
				{
					goalName = "Weekly Goal: " + wordGoal; 	
				}
			}
			
			var sql:String = "";
			if(goalId == -1)
			{
				sql += "INSERT INTO storyblue_goals " + 
						"(period_in_days, 		word_goal, 		story_id, 		 start_date,	end_date, 	active, 	name) VALUES " + 
						"("+ periodInDays +", 	"+wordGoal+", 	'"+ storyID +"', :start_date, 	:end_date,	true, 		'"+ goalName +"')";
			}
			else
			{
				sql += "UPDATE storyblue_goals SET period_in_days = " + periodInDays + ", word_goal = "+ wordGoal +
					", name = '"+ goalName +"', end_date = :end_date ";
				if(startDate != null) sql+= " , start_date = :start_date ";
				sql += " WHERE id = " + goalId;
			}
			
			var s:SQLStatement = new SQLStatement();
			s.text = sql;
			s.sqlConnection = conn;
			s.parameters[":end_date"] = endDate;
			if(goalId == -1 || startDate != null) 
			{
				s.parameters[":start_date"] = (startDate == null ? new Date() : startDate);
			}
			
			StoryDB.ExecGet(s);
		}
		
		//
		public function GetTotalWordsOverDateRange(start:Date, end:Date, storyID:String):int
		{
			var tot:int = 0;
			
			var sql:String = "select sum(word_count) as total from storyblue_wordcount " +
					"WHERE date(date) >= date(:start) " + 
					"AND date(date) <= date(:end) " + 
					"AND story_id = '" + storyID + "'";
			
			var g:SQLStatement = new SQLStatement();
			g.text = sql;
			g.parameters[":start"] = start;
			g.parameters[":end"] = end;
			
			g.sqlConnection = conn;
			
			var t:SQLResult = StoryDB.ExecGet(g);
			
			if(t != null && t.data != null)
			{
				tot = parseInt(t.data[0]["total"]);
			}
			
			return tot;
		}
		
		public function GetWordCountsOverDateRange(start:Date, end:Date, storyID:String, group:String="day", goal:Object = null):ArrayCollection
		{
			var res:Array = new Array();
			var iter:Date = new Date(start);
			
			var sql:String = "SELECT id, story_id, word_count, date FROM storyblue_wordcount " + 
					"WHERE date(date) >= date(:start) " + 
					"AND date(date) <= date(:end) " + 
					"AND story_id = '" + storyID + "'";
			
			var g:SQLStatement = new SQLStatement();
			g.text = sql;
			g.parameters[":start"] = start;
			g.parameters[":end"] = end;
			
			g.sqlConnection = conn;
			
			var all:SQLResult = StoryDB.ExecGet(g);
			
			if(all != null)
			{
				var lastDayWithData:Date = start;
				
				if(group == "week")
				{
					//collect all dates into array of dates
					//loop through, summing by weeks and adding calc'd val to res
					
					var dateArray:Array = new Array();
					
					for(var i:Number=0; i<all.data.length; i++)
					{
						var d:Date = new Date(all.data[i]["date"]);
						
						//if d's day is > lastDay+1, add some blank entries in there.
						if(lastDayWithData != null && d > lastDayWithData)
						{
	                		var iter:Date = lastDayWithData;
	                		while(iter < d)
	                		{
	                			dateArray.push({Words: 0, Date: iter.toDateString()});
	                			iter.setDate(iter.getDate()+1);
	                		}
						}
						
						dateArray.push({Words: all.data[i]["word_count"], Date: d.toDateString()});
						d.setDate(d.getDate()+1);
						lastDayWithData = d;
					}
					
					//have datearray: print in weeks
					var weekSum:Number = 0;
					var numWeeks:Number = 0;
					for(var i:Number=0; i<dateArray.length; i++)
					{
						if(new Date(Date.parse(dateArray[i].Date)).day == 0 && i>0) //first day; print sum and start over
						{
							res.push({Words: weekSum, Day: "Week "+numWeeks});
							weekSum = 0;
							numWeeks++;
						}
						weekSum += dateArray[i].Words;
					}
				}
				else if(group == "day")
				{
					var goalWords:int = null;
					if(goal!=null && goal.type == 'daily') 
					{
						goalWords = goal.word_goal;
					}
					else if(goal!=null && goal.type != 'daily')
					{
						//longterm
						//calc average
						goalWords = goal.totAve;
					}
					
					
					for(var i:Number=0; i<all.data.length; i++)
					{
						var d:Date = new Date(all.data[i]["date"]);
						
						//if d's day is > lastDay+1, add some blank entries in there.
						if(lastDayWithData != null && d > lastDayWithData)
						{
							//var tempDate:Date = new Date(d.getTime() - lastDayWithData.getTime());
	                		//var numDays:Number = Math.round((tempDate.time / MS_PER_DAY) + 1);
							var iter:Date = lastDayWithData;
							var days:int = Utilities.calculateDays(iter, d);//(d.time - iter.time) / MS_PER_DAY;
	                		//while(iter < d) //.date < d.date)
							for(var b=0; b<days; b++)
	                		{
								if(goal!=null&& Utilities.calculateDays(new Date(Date.parse(goal.start_date)), iter) <= 0) 
								{
									goalWords = null;
									res.push({Words: 0, Day: iter.getFullYear()+"-"+(iter.getMonth()+1)+"-"+iter.getDate() });
								}
								else if(goal!=null) 
								{
									goalWords = goal.totAve;
									res.push({Words: 0, Day: iter.getFullYear()+"-"+(iter.getMonth()+1)+"-"+iter.getDate(), Goal: goalWords });
								}
								else
								{
									res.push({Words: 0, Day: iter.getFullYear()+"-"+(iter.getMonth()+1)+"-"+iter.getDate() });
								}
	                			//res.push({Words: 0, Day: iter.getFullYear()+"-"+(iter.getMonth()+1)+"-"+iter.getDate(), Goal: goalWords });
	                			iter.setDate(iter.getDate()+1);
	                		}
						}
						
						if(goal!=null && Utilities.calculateDays(new Date(Date.parse(goal.start_date)), d) <= 0 ) 
						{
							goalWords = null;
							res.push({Words: all.data[i]["word_count"], Day: d.getFullYear()+"-"+(d.getMonth()+1)+"-"+d.getDate() });
						}
						else if(goal!=null) 
						{
							goalWords = goal.totAve;
							res.push({Words: all.data[i]["word_count"], Day: d.getFullYear()+"-"+(d.getMonth()+1)+"-"+d.getDate(), Goal: goalWords });
						}
						else
						{
							res.push({Words: all.data[i]["word_count"], Day: d.getFullYear()+"-"+(d.getMonth()+1)+"-"+d.getDate() });
						}
						
						d.setDate(d.getDate()+1);
						lastDayWithData = d;
					}
					
					//if lastdaywithdata < end-date, add some more blanks
					var daysTilEnd:int = Utilities.calculateDays(lastDayWithData, end);
					lastDayWithData.setDate(lastDayWithData.date - 1);
					iter = lastDayWithData;
					if(daysTilEnd > 0)
					{
						//add that number of blanks
						for(var c=0; c<daysTilEnd; c++)
						{
							if(goal!=null && Utilities.calculateDays(new Date(Date.parse(goal.start_date)), iter) <= 0 ) 
							{
								goalWords = null;
								res.push({Words:0, Day: iter.getFullYear()+"-"+(iter.getMonth()+1)+"-"+iter.getDate()});
							}
							else if(goal!=null) 
							{
								goalWords = goal.totAve;
								res.push({Words:0, Day: iter.getFullYear()+"-"+(iter.getMonth()+1)+"-"+iter.getDate(), Goal: goalWords });
							}
							else
							{
								res.push({Words:0, Day: iter.getFullYear()+"-"+(iter.getMonth()+1)+"-"+iter.getDate()});
							}
							
							iter.setDate(iter.getDate()+1);
						}
					}
				}
			}
			/*
			while(iter <= end)
			{
				var words:Number = 0;
				if(GetDay(iter) != null)
					words = GetDay(iter)["word_count"];
					
				res.push({Words: words, Day: iter.toDateString()});
				iter.setDate(iter.getDate()+1);
			}*/
			
			return new ArrayCollection(res);
		}
		
		/*
			Updates or creates entry for todays words
		*/
		public function UpdateDayWords(date:Date, total:Number, storyID:String)
		{
			var u:SQLStatement = new SQLStatement();
			u.sqlConnection = conn;
			
			var sql:String = "";
			
			var day:Object = GetDay(date, storyID);
			
			if(day != null)
			{
				sql += "UPDATE storyblue_wordcount SET ";
				sql += "word_count = " + total;
				sql += " WHERE id == " + day["id"];
			}
			else
			{
				//create
				sql += "INSERT INTO storyblue_wordcount (word_count, date, story_id) VALUES ('"+ total +"', :date, '"+ storyID +"')";
				u.parameters[":date"] = date;
			}
			
			u.text = sql;			
			
			u.execute();
		}
		
		/*
			Gets word count for a specific day
		*/
		public function GetDay(date:Date, storyID:String):Object
		{
			var u:SQLStatement = new SQLStatement();
			u.sqlConnection = conn;
			
			var sql:String = "SELECT id, word_count, date, story_id FROM storyblue_wordcount WHERE date(date) == date(:date) AND story_id == '" + storyID +"'";
			
			u.text = sql;
			u.parameters[":date"] = date;
			
			var res:SQLResult = StoryDB.ExecGet(u);
			if(res == null) return null;
			
			return res.data[0];
		}
	}
}