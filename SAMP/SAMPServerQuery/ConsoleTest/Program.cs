using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using SAMPServerQuery;

namespace ConsoleTest
{
    class Program
    {
        static async void OutputServerRules(ServerQuery serverQuery)
        {
            ServerRule[] serverRules = await serverQuery.QueryServerRulesAsync();

            foreach (var item in serverRules)
            {
                Console.WriteLine(item.RuleName + " : " + item.RuleValue);
            }
        }

        static void Main(string[] args)
        {
            ServerQuery serverQuery = new ServerQuery("125.65.108.173", 7777);

            ServerRule[] serverRules = serverQuery.QueryServerRules();
            Console.WriteLine("------------------Server Rules: ");
            foreach (var rule in serverRules)
            {
                Console.WriteLine(rule.RuleName + " : " + rule.RuleValue);
            }

            ServerInformation serverInfo = serverQuery.QueryServerInformation();
            Console.WriteLine("------------------Server Information: ");
            Console.WriteLine("GameMode : " + serverInfo.GameMode);
            Console.WriteLine("HostName : " + serverInfo.HostName);
            Console.WriteLine("IsPassword :" + serverInfo.IsPassword);
            Console.WriteLine("MapName : " + serverInfo.MapName);
            Console.WriteLine("MaxPlayers : " + serverInfo.MaxPlayers);
            Console.WriteLine("Players : " + serverInfo.Players);

            PlayerInformation[] playersInfo = serverQuery.QueryPlayersInformation();

            Console.WriteLine("------------------Player List: ");
            foreach (var playerInfo in playersInfo)
            {
                Console.WriteLine(playerInfo.Name + "|" + playerInfo.Score);
            }

            PlayerExtensionInformation[] playersExInfo = serverQuery.QueryPlayersExtensionInformation();

            Console.WriteLine("------------------Player ExList: ");
            foreach (var playerExInfo in playersExInfo)
            {
                Console.WriteLine(playerExInfo.Id + "|" + playerExInfo.Name + "|" + playerExInfo.Score + "|" + playerExInfo.Ping);
            }

            Console.WriteLine("------------------Server Ping: ");
            Console.WriteLine("Ping : " + serverQuery.QueryPing().Milliseconds);

            Console.WriteLine("------------------异步查询演示: ");

            OutputServerRules(serverQuery);

            Console.WriteLine("我比异步查询先输出，所以说异步查询没有阻塞线程");
            Console.ReadLine();
        }
    }
}
