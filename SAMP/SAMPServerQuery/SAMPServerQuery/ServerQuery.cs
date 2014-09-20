using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Net;
using System.Net.Sockets;
using System.IO;

namespace SAMPServerQuery
{
    internal enum QueryType : byte
    {
        ServerInformation = (byte)'i',
        ServerRules = (byte)'r',
        ServerPing = (byte)'p',
        PlayerInformation = (byte)'c',
        PlayerExtensionInformation = (byte)'d',
    }

    internal static class Packet
    {
        static readonly byte[] SAMP = ASCIIEncoding.ASCII.GetBytes("SAMP");
        static readonly Random random = new Random();

        public static byte[] HeaderBytes(byte[] addressIPv4, byte[] port, QueryType opcode)
        {
            List<byte> packet = new List<byte>(SAMP);
            packet.AddRange(addressIPv4);
            packet.AddRange(port);
            packet.Add((byte)opcode);
            return packet.ToArray();
        }

        public static byte[] PingPacketBytes(byte[] addressIPv4, byte[] port)
        {
            List<byte> packet = new List<byte>(HeaderBytes(addressIPv4, port, QueryType.ServerPing));
            packet.Add((byte)random.Next(256));
            packet.Add((byte)random.Next(256));
            packet.Add((byte)random.Next(256));
            packet.Add((byte)random.Next(256));
            return packet.ToArray();
        }
    }

    public struct ServerRule
    {
        public readonly string RuleName;
        public readonly string RuleValue;

        public ServerRule(string ruleName, string ruleValue)
        {
            RuleName = ruleName;
            RuleValue = ruleValue;
        }
    }

    public struct ServerInformation
    {
        public readonly bool IsPassword;
        public readonly int Players;
        public readonly int MaxPlayers;
        public readonly string HostName;
        public readonly string GameMode;
        public readonly string MapName;

        public ServerInformation(bool isPassword, int players, int maxPlayers, string hostname, string gamemode, string mapname)
        {
            IsPassword = isPassword;
            Players = players;
            MaxPlayers = maxPlayers;
            HostName = hostname;
            GameMode = gamemode;
            MapName = mapname;
        }
    }

    public struct PlayerInformation
    {
        public readonly int Score;
        public readonly string Name;

        public PlayerInformation(string name, int score)
        {
            Score = score;
            Name = name;
        }
    }

    public struct PlayerExtensionInformation
    {
        public readonly int Id;
        public readonly string Name;
        public readonly int Score;
        public readonly int Ping;

        public PlayerExtensionInformation(int id, string name, int score, int ping)
        {
            Id = id;
            Name = name;
            Score = score;
            Ping = ping;
        }
    }

    public class ServerQuery : IDisposable
    {
        UdpClient udpClient;

        public ServerQuery()
        {
            udpClient = new UdpClient();
            udpClient.Client.ReceiveTimeout = 10000;
        }

        public ServerQuery(AddressFamily family)
        {
            udpClient = new UdpClient(family);
            udpClient.Client.ReceiveTimeout = 10000;
        }

        public ServerQuery(int port)
        {
            udpClient = new UdpClient(port);
            udpClient.Client.ReceiveTimeout = 10000;
        }

        public ServerQuery(IPEndPoint localEP)
        {
            udpClient = new UdpClient(localEP);
            udpClient.Client.ReceiveTimeout = 10000;
        }

        public ServerQuery(int port, AddressFamily family)
        {
            udpClient = new UdpClient(family);
            udpClient.Client.ReceiveTimeout = 10000;
        }

        public ServerQuery(string hostname, int port)
        {
            udpClient = new UdpClient(hostname, port);
            udpClient.Client.ReceiveTimeout = 10000;
        }

        public void Connect(IPEndPoint endPoint)
        {
            udpClient.Connect(endPoint);
        }

        public void Connect(IPAddress addr, int port)
        {
            udpClient.Connect(addr, port);
        }

        public void Connect(String hostname, int port)
        {
            udpClient.Connect(hostname, port);
        }

        public void Close()
        {
            udpClient.Close();
        }

        void RemoteEndPointToBytes(out byte[] ip, out byte[] port)
        {
            ip = new byte[4];
            port = new byte[2];

            var strIP = IPAddress.Parse(((IPEndPoint)udpClient.Client.RemoteEndPoint).Address.ToString()).ToString().Split('.');

            for (int i = 0; i < ip.Length; i++)
            {
                ip[i] = byte.Parse(strIP[i]);
            }

            var intPort = ((IPEndPoint)udpClient.Client.RemoteEndPoint).Port;
            port[0] = (byte)(intPort & 0xFF);
            port[1] = (byte)(intPort >> 8 & 0xFF);
        }

        void RemoteEndPointToBytes(out byte[] ip, out byte[] port, IPEndPoint endPoint)
        {
            ip = new byte[4];
            port = new byte[2];

            var strIP = endPoint.Address.ToString().Split('.');

            for (int i = 0; i < ip.Length; i++)
            {
                ip[i] = byte.Parse(strIP[i]);
            }

            var intPort = endPoint.Port;
            port[0] = (byte)(intPort & 0xFF);
            port[1] = (byte)(intPort >> 8 & 0xFF);
        }

        void RemoteEndPointToBytes(out byte[] ip, out byte[] port, string hostname, int iport)
        {
            IPEndPoint endPoint = new IPEndPoint(Dns.GetHostAddresses(hostname)[0], iport);
            RemoteEndPointToBytes(out ip, out port, endPoint);
        }

        void PacketFormat(out ServerRule[] serverRules, byte[] receivePacketBytes)
        {
            using (MemoryStream stream = new MemoryStream(receivePacketBytes))
            {
                using (BinaryReader reader = new BinaryReader(stream))
                {
                    reader.ReadBytes(11);

                    int ruleCount = reader.ReadInt16();
                    serverRules = new ServerRule[ruleCount];//jvxf2m1

                    for (int i = 0; i < ruleCount; i++)
                    {
                        int ruleNameLength = reader.ReadByte();
                        byte[] ruleName = reader.ReadBytes(ruleNameLength);

                        int ruleValueLength = reader.ReadByte();
                        byte[] ruleValue = reader.ReadBytes(ruleValueLength);

                        serverRules[i] = new ServerRule(Encoding.Default.GetString(ruleName), Encoding.Default.GetString(ruleValue));
                    }
                }
            }
        }

        void PacketFormat(out ServerInformation serverInfo, byte[] receivePacketBytes)
        {
            using (MemoryStream stream = new MemoryStream(receivePacketBytes))
            {
                using (BinaryReader reader = new BinaryReader(stream))
                {
                    reader.ReadBytes(11);

                    bool isPassword = reader.ReadByte() == 0 ? false : true;
                    int players = reader.ReadInt16();
                    int maxPlayers = reader.ReadInt16();
                    int stringLength = reader.ReadInt32();
                    string hostName = Encoding.Default.GetString(reader.ReadBytes(stringLength));
                    stringLength = reader.ReadInt32();
                    string gamemode = Encoding.Default.GetString(reader.ReadBytes(stringLength));
                    stringLength = reader.ReadInt32();
                    string mapName = Encoding.Default.GetString(reader.ReadBytes(stringLength));

                    serverInfo = new ServerInformation(isPassword, players, maxPlayers, hostName, gamemode, mapName);
                }
            }
        }

        void PacketFormat(out PlayerInformation[] playersInformation, byte[] receivePacketBytes)
        {
            using (MemoryStream stream = new MemoryStream(receivePacketBytes))
            {
                using (BinaryReader reader = new BinaryReader(stream))
                {
                    reader.ReadBytes(11);
                    int playerCount = reader.ReadInt16();
                    playersInformation = new PlayerInformation[playerCount];
                    for (int i = 0; i < playerCount; i++)
                    {
                        int stringLength = reader.ReadByte();
                        string playerName = Encoding.Default.GetString(reader.ReadBytes(stringLength));
                        int score = reader.ReadInt32();
                        playersInformation[i] = new PlayerInformation(playerName, score);
                    }
                }
            }
        }

        void PacketFormat(out PlayerExtensionInformation[] playersExtensionInformation, byte[] receivePacketBytes)
        {
            using (MemoryStream stream = new MemoryStream(receivePacketBytes))
            {
                using (BinaryReader reader = new BinaryReader(stream))
                {
                    reader.ReadBytes(11);
                    int playerCount = reader.ReadInt16();
                    playersExtensionInformation = new PlayerExtensionInformation[playerCount];
                    for (int i = 0; i < playerCount; i++)
                    {
                        int id = reader.ReadByte();
                        int stringLength = reader.ReadByte();
                        string name = Encoding.Default.GetString(reader.ReadBytes(stringLength));
                        int score = reader.ReadInt32();
                        int ping = reader.ReadInt32();
                        playersExtensionInformation[i] = new PlayerExtensionInformation(id, name, score, ping);
                    }
                }
            }
        }

        public ServerRule[] QueryServerRules()
        {
            byte[] serverIP;
            byte[] serverPort;
            RemoteEndPointToBytes(out serverIP, out serverPort);

            var sendPacketBytes = Packet.HeaderBytes(serverIP, serverPort, QueryType.ServerRules);
            udpClient.Send(sendPacketBytes, sendPacketBytes.Length);

            IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
            var receivePacketBytes = udpClient.Receive(ref remoteEP);

            ServerRule[] serverRules;

            PacketFormat(out serverRules, receivePacketBytes);

            return serverRules;
        }

        public ServerRule[] QueryServerRules(IPEndPoint endPoint)
        {
            byte[] serverIP;
            byte[] serverPort;
            RemoteEndPointToBytes(out serverIP, out serverPort, endPoint);

            var sendPacketBytes = Packet.HeaderBytes(serverIP, serverPort, QueryType.ServerRules);
            udpClient.Send(sendPacketBytes, sendPacketBytes.Length, endPoint);

            IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
            var receivePacketBytes = udpClient.Receive(ref remoteEP);

            ServerRule[] serverRules;

            PacketFormat(out serverRules, receivePacketBytes);

            return serverRules;
        }

        public ServerRule[] QueryServerRules(string hostname, int port)
        {
            byte[] serverIP;
            byte[] serverPort;
            RemoteEndPointToBytes(out serverIP, out serverPort, hostname, port);

            var sendPacketBytes = Packet.HeaderBytes(serverIP, serverPort, QueryType.ServerRules);
            udpClient.Send(sendPacketBytes, sendPacketBytes.Length, hostname, port);

            IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
            var receivePacketBytes = udpClient.Receive(ref remoteEP);

            ServerRule[] serverRules;

            PacketFormat(out serverRules, receivePacketBytes);

            return serverRules;
        }

        public Task<ServerRule[]> QueryServerRulesAsync()
        {
            var task = new Task<ServerRule[]>(() =>
            {
                return QueryServerRules();
            });

            task.Start();

            return task;
        }

        public Task<ServerRule[]> QueryServerRulesAsync(IPEndPoint endPoint)
        {
            var task = new Task<ServerRule[]>(() =>
            {
                return QueryServerRules(endPoint);
            });

            task.Start();

            return task;
        }

        public Task<ServerRule[]> QueryServerRulesAsync(string hostname, int port)
        {
            var task = new Task<ServerRule[]>(() =>
            {
                return QueryServerRules(hostname, port);
            });

            task.Start();

            return task;
        }

        public ServerInformation QueryServerInformation()
        {
            byte[] serverIP;
            byte[] serverPort;
            RemoteEndPointToBytes(out serverIP, out serverPort);

            var sendPacketBytes = Packet.HeaderBytes(serverIP, serverPort, QueryType.ServerInformation);
            udpClient.Send(sendPacketBytes, sendPacketBytes.Length);

            IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
            var receivePacketBytes = udpClient.Receive(ref remoteEP);

            ServerInformation serverInfo;

            PacketFormat(out serverInfo, receivePacketBytes);

            return serverInfo;
        }

        public ServerInformation QueryServerInformation(IPEndPoint endPoint)
        {
            byte[] serverIP;
            byte[] serverPort;
            RemoteEndPointToBytes(out serverIP, out serverPort, endPoint);

            var sendPacketBytes = Packet.HeaderBytes(serverIP, serverPort, QueryType.ServerInformation);
            udpClient.Send(sendPacketBytes, sendPacketBytes.Length, endPoint);

            IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
            var receivePacketBytes = udpClient.Receive(ref remoteEP);

            ServerInformation serverInfo;

            PacketFormat(out serverInfo, receivePacketBytes);

            return serverInfo;
        }

        public ServerInformation QueryServerInformation(string hostname, int port)
        {
            byte[] serverIP;
            byte[] serverPort;
            RemoteEndPointToBytes(out serverIP, out serverPort, hostname, port);

            var sendPacketBytes = Packet.HeaderBytes(serverIP, serverPort, QueryType.ServerInformation);
            udpClient.Send(sendPacketBytes, sendPacketBytes.Length, hostname, port);

            IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
            var receivePacketBytes = udpClient.Receive(ref remoteEP);

            ServerInformation serverInfo;

            PacketFormat(out serverInfo, receivePacketBytes);

            return serverInfo;
        }

        public Task<ServerInformation> QueryServerInformationAsync()
        {
            var task = new Task<ServerInformation>(() =>
            {
                return QueryServerInformation();
            });

            task.Start();

            return task;
        }

        public Task<ServerInformation> QueryServerInformationAsync(IPEndPoint endPoint)
        {
            var task = new Task<ServerInformation>(() =>
            {
                return QueryServerInformation(endPoint);
            });

            task.Start();

            return task;
        }

        public Task<ServerInformation> QueryServerInformationAsync(string hostname, int port)
        {
            var task = new Task<ServerInformation>(() =>
            {
                return QueryServerInformation(hostname, port);
            });

            task.Start();

            return task;
        }

        public PlayerInformation[] QueryPlayersInformation()
        {
            byte[] serverIP;
            byte[] serverPort;
            RemoteEndPointToBytes(out serverIP, out serverPort);

            var sendPacketBytes = Packet.HeaderBytes(serverIP, serverPort, QueryType.PlayerInformation);
            udpClient.Send(sendPacketBytes, sendPacketBytes.Length);

            IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
            var receivePacketBytes = udpClient.Receive(ref remoteEP);

            PlayerInformation[] playersInfo;

            PacketFormat(out playersInfo, receivePacketBytes);

            return playersInfo;
        }

        public PlayerInformation[] QueryPlayersInformation(IPEndPoint endPoint)
        {
            byte[] serverIP;
            byte[] serverPort;
            RemoteEndPointToBytes(out serverIP, out serverPort, endPoint);

            var sendPacketBytes = Packet.HeaderBytes(serverIP, serverPort, QueryType.PlayerInformation);
            udpClient.Send(sendPacketBytes, sendPacketBytes.Length, endPoint);

            IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
            var receivePacketBytes = udpClient.Receive(ref remoteEP);

            PlayerInformation[] playersInfo;

            PacketFormat(out playersInfo, receivePacketBytes);

            return playersInfo;
        }

        public PlayerInformation[] QueryPlayersInformation(string hostname, int port)
        {
            byte[] serverIP;
            byte[] serverPort;
            RemoteEndPointToBytes(out serverIP, out serverPort, hostname, port);

            var sendPacketBytes = Packet.HeaderBytes(serverIP, serverPort, QueryType.PlayerInformation);
            udpClient.Send(sendPacketBytes, sendPacketBytes.Length, hostname, port);

            IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
            var receivePacketBytes = udpClient.Receive(ref remoteEP);

            PlayerInformation[] playersInfo;

            PacketFormat(out playersInfo, receivePacketBytes);

            return playersInfo;
        }

        public Task<PlayerInformation[]> QueryPlayersInformationAsync()
        {
            var task = new Task<PlayerInformation[]>(() =>
            {
                return QueryPlayersInformation();
            });

            task.Start();

            return task;
        }

        public Task<PlayerInformation[]> QueryPlayersInformationAsync(IPEndPoint endPoint)
        {
            var task = new Task<PlayerInformation[]>(() =>
            {
                return QueryPlayersInformation(endPoint);
            });

            task.Start();

            return task;
        }

        public Task<PlayerInformation[]> QueryPlayersInformationAsync(string hostname, int port)
        {
            var task = new Task<PlayerInformation[]>(() =>
            {
                return QueryPlayersInformation(hostname, port);
            });

            task.Start();

            return task;
        }

        public PlayerExtensionInformation[] QueryPlayersExtensionInformation()
        {
            byte[] serverIP;
            byte[] serverPort;
            RemoteEndPointToBytes(out serverIP, out serverPort);

            var sendPacketBytes = Packet.HeaderBytes(serverIP, serverPort, QueryType.PlayerExtensionInformation);
            udpClient.Send(sendPacketBytes, sendPacketBytes.Length);

            IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
            var receivePacketBytes = udpClient.Receive(ref remoteEP);

            PlayerExtensionInformation[] playersInfo;

            PacketFormat(out playersInfo, receivePacketBytes);

            return playersInfo;
        }

        public PlayerExtensionInformation[] QueryPlayersExtensionInformation(IPEndPoint endPoint)
        {
            byte[] serverIP;
            byte[] serverPort;
            RemoteEndPointToBytes(out serverIP, out serverPort, endPoint);

            var sendPacketBytes = Packet.HeaderBytes(serverIP, serverPort, QueryType.PlayerExtensionInformation);
            udpClient.Send(sendPacketBytes, sendPacketBytes.Length, endPoint);

            IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
            var receivePacketBytes = udpClient.Receive(ref remoteEP);

            PlayerExtensionInformation[] playersInfo;

            PacketFormat(out playersInfo, receivePacketBytes);

            return playersInfo;
        }

        public PlayerExtensionInformation[] QueryPlayersExtensionInformation(string hostname, int port)
        {
            byte[] serverIP;
            byte[] serverPort;
            RemoteEndPointToBytes(out serverIP, out serverPort, hostname, port);

            var sendPacketBytes = Packet.HeaderBytes(serverIP, serverPort, QueryType.PlayerExtensionInformation);
            udpClient.Send(sendPacketBytes, sendPacketBytes.Length, hostname, port);

            IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
            var receivePacketBytes = udpClient.Receive(ref remoteEP);

            PlayerExtensionInformation[] playersInfo;

            PacketFormat(out playersInfo, receivePacketBytes);

            return playersInfo;
        }

        public Task<PlayerExtensionInformation[]> QueryPlayersExtensionInformationAsync()
        {
            var task = new Task<PlayerExtensionInformation[]>(() =>
            {
                return QueryPlayersExtensionInformation();
            });

            task.Start();

            return task;
        }

        public Task<PlayerExtensionInformation[]> QueryPlayersExtensionInformationAsync(IPEndPoint endPoint)
        {
            var task = new Task<PlayerExtensionInformation[]>(() =>
            {
                return QueryPlayersExtensionInformation(endPoint);
            });

            task.Start();

            return task;
        }

        public Task<PlayerExtensionInformation[]> QueryPlayersExtensionInformationAsync(string hostname, int port)
        {
            var task = new Task<PlayerExtensionInformation[]>(() =>
            {
                return QueryPlayersExtensionInformation(hostname, port);
            });

            task.Start();

            return task;
        }

        public TimeSpan QueryPing()
        {
            byte[] serverIP;
            byte[] serverPort;
            RemoteEndPointToBytes(out serverIP, out serverPort);

            var sendPacketBytes = Packet.PingPacketBytes(serverIP, serverPort);

            DateTime sendTime = DateTime.Now;

            udpClient.Send(sendPacketBytes, sendPacketBytes.Length);

            IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
            var receivePacketBytes = udpClient.Receive(ref remoteEP);

            return DateTime.Now - sendTime;
        }

        public TimeSpan QueryPing(IPEndPoint endPoint)
        {
            byte[] serverIP;
            byte[] serverPort;
            RemoteEndPointToBytes(out serverIP, out serverPort, endPoint);

            var sendPacketBytes = Packet.PingPacketBytes(serverIP, serverPort);

            DateTime sendTime = DateTime.Now;

            udpClient.Send(sendPacketBytes, sendPacketBytes.Length, endPoint);

            IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
            var receivePacketBytes = udpClient.Receive(ref remoteEP);

            return DateTime.Now - sendTime;
        }

        public TimeSpan QueryPing(string hostname, int port)
        {
            byte[] serverIP;
            byte[] serverPort;
            RemoteEndPointToBytes(out serverIP, out serverPort, hostname, port);

            var sendPacketBytes = Packet.PingPacketBytes(serverIP, serverPort);

            DateTime sendTime = DateTime.Now;

            udpClient.Send(sendPacketBytes, sendPacketBytes.Length, hostname, port);

            IPEndPoint remoteEP = new IPEndPoint(IPAddress.Any, 0);
            var receivePacketBytes = udpClient.Receive(ref remoteEP);

            return DateTime.Now - sendTime;
        }

        public Task<TimeSpan> QueryPingAsync()
        {
            var task = new Task<TimeSpan>(() =>
            {
                return QueryPing();
            });

            task.Start();

            return task;
        }

        public Task<TimeSpan> QueryPingAsync(IPEndPoint endPoint)
        {
            var task = new Task<TimeSpan>(() =>
            {
                return QueryPing(endPoint);
            });

            task.Start();

            return task;
        }

        public Task<TimeSpan> QueryPingAsync(string hostname, int port)
        {
            var task = new Task<TimeSpan>(() =>
            {
                return QueryPing(hostname, port);
            });

            task.Start();

            return task;
        }

        void IDisposable.Dispose()
        {
            using (udpClient) { }
        }
    }
}
