using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class test : MonoBehaviour
{
    public Image CurImage;

    public Material WaveMat;

    public int index = 2;

    private float time;

	// Use this for initialization
	void Start ()
	{
        switch (index)
        {
            case 1:
                SetSingleUv();
                break;
            case 2:
                SetSingleUv_2();
                break;
        }

	    time = 0;
	}

    // Update is called once per frame
    void Update () {

        time = Mathf.Min(time + Time.deltaTime * 0.25f, 1);

        for (int i = 0; i < 2; i++)
        {
            WaveMat.SetFloat("_Threshold", time);
        }
    }

    private void SetSingleUv_2()
    {
        Vector4 temp = new Vector4(1,1,0,0);

        for (int i = 0; i < CurImage.sprite.uv.Length; i++)
        {
            temp.x = Mathf.Min(CurImage.sprite.uv[i].x, temp.x);
            temp.y = Mathf.Min(CurImage.sprite.uv[i].y, temp.y);
            temp.z = Mathf.Max(CurImage.sprite.uv[i].x, temp.z);
            temp.w = Mathf.Max(CurImage.sprite.uv[i].y, temp.w);
        }

        WaveMat.SetVector("_uvRange", temp);

        Debug.Log(temp);
            
    }


    private void SetSingleUv()
    {
        Vector4 temp = new Vector4(CurImage.sprite.uv[2].x, CurImage.sprite.uv[2].y,
            CurImage.sprite.uv[1].x, CurImage.sprite.uv[1].y);

        WaveMat.SetVector("_uvRange", temp);
    }
}
