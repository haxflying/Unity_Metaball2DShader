using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MZ_MetaballDrawer : MonoBehaviour {

    public struct Metaball
    {
        public float radius;
        public Vector3 position;
        public Vector4 color;
    }
    public GameObject Atom;
    [Range(1,30)]
    public int count = 10;
    [Range(0.05f,0.2f)]
    public float radiu = 0.02f;
    public Color color;

    Material mat;
    Metaball[] metaballs;
    ComputeBuffer metaballBuffer;
    List<GameObject> atoms = new List<GameObject>();
    private void OnEnable()
    {      
        Init();
    }

    private void Update()
    {
        for (int i = 0; i < this.metaballs.Length; i++)
        {
            metaballs[i].position = atoms[i].transform.position;
        }
        metaballBuffer.SetData(metaballs);
        mat.SetBuffer("_MetaballBuffer", metaballBuffer);
        mat.SetVector("_ObjectPos", transform.position);
    }

    void Init()
    {
        transform.localScale *= count / 10f;
        mat = GetComponent<Renderer>().material;
        metaballBuffer = new ComputeBuffer(count, System.Runtime.InteropServices.Marshal.SizeOf(typeof(Metaball)));
        metaballs = new Metaball[metaballBuffer.count];

        for (int i = 0; i < metaballs.Length; i++)
        {
            metaballs[i] = new Metaball()
            {
                radius = Random.Range(radiu / 1.5f, radiu),
                position = Random.insideUnitSphere * transform.lossyScale.x / 1.5f,
                color = color,
            };
            GameObject atom = Instantiate(Atom, metaballs[i].position, Quaternion.identity, transform);
            atom.GetComponent<DrawGizmos>().center = transform.position;            
            atoms.Add(atom);
        }

        metaballBuffer.SetData(metaballs);
        mat.SetBuffer("_MetaballBuffer", metaballBuffer);
        print("inited");
    }
}
