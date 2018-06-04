using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ShaderHelper : MonoBehaviour
{
    public Image CurImage;

    public Material TargetMat;

    private float time;

	void Start ()
	{
        SetSingleUv();

	    //time = 0;
	}

    // void Update () 
    // {
    // }

    // Set SpriteUv to Shader 
    private void SetSingleUv()
    {
        Vector4 temp = new Vector4(1,1,0,0);

        for (int i = 0; i < CurImage.sprite.uv.Length; i++)
        {
            temp.x = Mathf.Min(CurImage.sprite.uv[i].x, temp.x);
            temp.y = Mathf.Min(CurImage.sprite.uv[i].y, temp.y);
            temp.z = Mathf.Max(CurImage.sprite.uv[i].x, temp.z);
            temp.w = Mathf.Max(CurImage.sprite.uv[i].y, temp.w);
        }

        TargetMat.SetVector("_uvRange", temp);   
    }

    // Update Some Value from Time
    private void UpdateFromTime(string temp)
    {
        time = Mathf.Min(time + Time.deltaTime * 0.25f, 1);

        TargetMat.SetFloat("temp", time);
    }

}
