﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraControl : MonoBehaviour
{
    private float Speed = 3;
    private Vector3 MouseDownPos;

    void Update()
    {
        Vector3 Face = transform.rotation * Vector3.forward;
        Face = Face.normalized;

        Vector3 Left = transform.rotation * Vector3.left;
        Left = Left.normalized;

        Vector3 Right = transform.rotation * Vector3.right;
        Right = Right.normalized;

        if (Input.GetMouseButtonDown(1))
        {
            MouseDownPos = Input.mousePosition;
        }

        if (Input.GetMouseButton(0))
        {
            //Vector处理
            Vector3 Save = Input.mousePosition;
            Vector3 MovePos = Save - MouseDownPos;
            MovePos = MovePos.normalized;
            Vector3 _Rot = transform.rotation.eulerAngles;
            _Rot.x -= MovePos.y * 2;
            _Rot.y += MovePos.x * 2;
            _Rot.z += MovePos.z * 2;
            transform.eulerAngles = _Rot;
            Debug.Log(MovePos);
            MouseDownPos = Save;

            //Quaternion处理
            //Vector3 Save = Input.mousePosition;
            //Vector3 MovePos = Save - MouseDownPos;
            //MovePos = MovePos.normalized;
            //Vector3 _Rot = transform.rotation.eulerAngles;
            //_Rot.x -= MovePos.y * 2;
            //_Rot.y += MovePos.x * 2;
            //_Rot.z += MovePos.z * 2;
            //Quaternion MoveRot = Quaternion.Euler(_Rot);
            //transform.rotation = Quaternion.Slerp(transform.rotation, MoveRot, Time.deltaTime * 30);
            //MouseDownPos = Save;
        }

        if (Input.GetKey("w"))
        {
            transform.position += Face * Speed * Time.deltaTime;
        }

        if (Input.GetKey("a"))
        {
            transform.position += Left * Speed * Time.deltaTime;
        }

        if (Input.GetKey("d"))
        {
            transform.position += Right * Speed * Time.deltaTime;
        }

        if (Input.GetKey("s"))
        {
            transform.position -= Face * Speed * Time.deltaTime;
        }

        if (Input.GetKey("q"))
        {
            transform.position -= Vector3.up * Speed * Time.deltaTime;
        }

        if (Input.GetKey("e"))
        {
            transform.position += Vector3.up * Speed * Time.deltaTime;
        }

    }

}
