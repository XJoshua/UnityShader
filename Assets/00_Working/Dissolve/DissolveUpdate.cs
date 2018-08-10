using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DissolveUpdate : MonoBehaviour 
{
	public Material DissolveMat;

	public float time;

	public float ScaleTime = 0.5f;

	void Start () 
	{
		time = 0;
		DissolveMat.SetFloat("_Threshold", 0);
	}
	
	void Update () 
	{
		if(time > 1)
		{
			time = 0;
		}
		else
		{
			time += Time.deltaTime * ScaleTime;
		}

		DissolveMat.SetFloat("_Threshold", time);
	}
}
