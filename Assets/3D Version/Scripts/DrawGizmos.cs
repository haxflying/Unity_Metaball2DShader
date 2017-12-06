using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawGizmos : MonoBehaviour {

    public Vector3 center;
    Rigidbody rg;

	void Start () {
        rg = GetComponent<Rigidbody>();	
	}
	
	void Update () {
        rg.AddForce((center - transform.position) * 0.4f + Random.insideUnitSphere);
	}

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.cyan;
        Gizmos.DrawWireSphere(transform.position, 0.2f);
    }
}
