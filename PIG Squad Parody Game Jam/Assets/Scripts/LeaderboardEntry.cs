using UnityEngine;
using UnityEngine.UI;

public class LeaderboardEntry : MonoBehaviour
{
    public Text nameText;
    public Text scoreText;

    private void Awake()
    {
        nameText = transform.Find("Name").GetComponent<Text>();
        scoreText = transform.Find("Score").GetComponent<Text>();
    }

    public void SetLeaderboardEntry(string nameText, string scoreText)
    {
        this.nameText.text = nameText;
        this.scoreText.text = scoreText;
    }
}
