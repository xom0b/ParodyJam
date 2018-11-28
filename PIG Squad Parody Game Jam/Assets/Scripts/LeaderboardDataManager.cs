using UnityEngine;
using System.Runtime.Serialization.Formatters.Binary;
using System.IO;
using System.Collections.Generic;


public class LeaderboardDataManager : MonoBehaviour
{
    public List<LeaderboardEntry> leaderboardEntries;

    [System.Serializable]
    public class LeaderboardData
    {
        public string playerName = "WONK";
        public string playerScore = "000.0";
    }

    LeaderboardData[] top30Scores = new LeaderboardData[30];

    // Use this for initialization
    void Start()
    {
        Load();
        PopulateUI();
    }

    private void PopulateUI()
    {
        for(int i = 0; i < top30Scores.Length; i++)
        {
            if (i < leaderboardEntries.Count)
            {
                leaderboardEntries[i].SetLeaderboardEntry(top30Scores[i].playerName, top30Scores[i].playerScore);
            }
        }
    }

    private void Save()
    {
        BinaryFormatter binaryFormatter = new BinaryFormatter();
        FileStream file = File.Open(Application.persistentDataPath + "/highScores.dat", FileMode.OpenOrCreate);
        binaryFormatter.Serialize(file, top30Scores);
        file.Close();
    }

    private void Load()
    {
        Debug.Log(Application.persistentDataPath + "/highScores.dat");
        if (File.Exists(Application.persistentDataPath + "/highScores.dat"))
        {
            BinaryFormatter binaryFormatter = new BinaryFormatter();
            FileStream file = File.Open(Application.persistentDataPath + "/highScores.dat", FileMode.Open);
            top30Scores = (LeaderboardData[])binaryFormatter.Deserialize(file);
            file.Close();
        }
        else
        {
            for(int i = 0; i < top30Scores.Length; i++)
            {
                top30Scores[i] = new LeaderboardData();
            }

            Save();
        }
    }
}
