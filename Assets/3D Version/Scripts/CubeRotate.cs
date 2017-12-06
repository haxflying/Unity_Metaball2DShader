using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CubeRotate : MonoBehaviour {
	
	void Update () {
        transform.rotation *= Quaternion.Euler(Vector3.one * 0.2f);
	}
}
