using UnityEngine;
using System.Runtime.Serialization.Formatters.Binary;
using System.IO;
using System.Collections.Generic;
using System.Linq;
using System;

public class LeaderboardDataManager : MonoBehaviour
{
    public List<LeaderboardEntry> leaderboardEntries;
    public bool clearDataOnLoad;

    [Header("Hue Animation Settings")]
    public bool animateEntryColor;
    public float saturation;
    public float value;
    public float hueSpeed;

    [System.Serializable]
    public class LeaderboardData
    {
        public string playerName;
        public string playerScore;

        public LeaderboardData()
        {
            playerName = "WONK";
            playerScore = "000.0";
        }

        public LeaderboardData(string pn, string ps)
        {
            playerName = pn;
            playerScore = ps;
        }
    }

    private LinkedList<LeaderboardData> top30Scores = new LinkedList<LeaderboardData>();
    private LeaderboardData lastAddedData = null;
    private LeaderboardEntry lastAddedEntry = null;

    private static LeaderboardDataManager instance;

    private void Awake()
    {
        instance = this;
    }

    public static bool TryGetInstance(out LeaderboardDataManager manager)
    {
        manager = instance;
        return (manager != null);
    }

    // Use this for initialization
    void Start()
    {
        if (clearDataOnLoad)
        {
            ClearData();
        }

        Load();
        PopulateUI();
    }

    private void PopulateUI()
    {
        LeaderboardData[] top30ScoresArr = top30Scores.ToArray();
        for(int i = 0; i < top30ScoresArr.Length; i++)
        {
            if (i < leaderboardEntries.Count)
            {
                if (top30ScoresArr[i] == lastAddedData && animateEntryColor)
                {
                    lastAddedEntry = leaderboardEntries[i];
                    lastAddedEntry.InitializeHueAnimator(saturation, value, hueSpeed);
                }

                leaderboardEntries[i].SetLeaderboardEntry(top30ScoresArr[i].playerName, top30ScoresArr[i].playerScore);
            }
        }
    }

    public void StopLastAddedAnimation()
    {
        if (lastAddedData != null && lastAddedEntry != null && animateEntryColor)
        {
            lastAddedEntry.DisableHueAnimator();
            lastAddedData = null;
            lastAddedEntry = null;
        }
    }

    public void AddHighScore(string playerName, string playerScore)
    {
        float playerScoreFloat = float.Parse(playerScore);

        LeaderboardData leaderboardDataToFind = null;

        foreach(LeaderboardData leaderboardData in top30Scores)
        {
            float entryScore = float.Parse(leaderboardData.playerScore);
            if (entryScore <= playerScoreFloat)
            {
                leaderboardDataToFind = leaderboardData;
                break;
            }
        }

        if (leaderboardDataToFind != null)
        {
            LinkedListNode<LeaderboardData> leaderboardNode = top30Scores.Find(leaderboardDataToFind);
            if (leaderboardNode != null)
            {
                LeaderboardData newLeaderBoardData = new LeaderboardData(playerName, playerScore);
                lastAddedData = newLeaderBoardData;
                top30Scores.AddBefore(leaderboardNode, newLeaderBoardData);
            }
        }

        PopulateUI();
        Save();
    }

    private void Save()
    {
        BinaryFormatter binaryFormatter = new BinaryFormatter();
        FileStream file = File.Open(Application.persistentDataPath + "/highScores.dat", FileMode.OpenOrCreate);
        binaryFormatter.Serialize(file, top30Scores);
        file.Close();
    }

    private void ClearData()
    {
        if (File.Exists(Application.persistentDataPath + "/highScores.dat"))
        {
            File.Delete(Application.persistentDataPath + "/highScores.dat");
        }
    }

    private void Load()
    {
        if (File.Exists(Application.persistentDataPath + "/highScores.dat"))
        {
            BinaryFormatter binaryFormatter = new BinaryFormatter();
            FileStream file = File.Open(Application.persistentDataPath + "/highScores.dat", FileMode.Open);
            top30Scores = (LinkedList<LeaderboardData>)binaryFormatter.Deserialize(file);
            file.Close();
        }
        else
        {
            for(int i = 0; i < leaderboardEntries.Count; i++)
            {
                top30Scores.AddLast(new LeaderboardData());
            }

            Save();
        }
    }
}
