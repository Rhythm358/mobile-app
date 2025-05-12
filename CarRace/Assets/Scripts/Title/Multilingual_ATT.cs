#if UNITY_IOS
using Unity.Advertisement.IosSupport;
#endif
using UnityEngine;

public class Multilingual_ATT : MonoBehaviour
{
    public void Start()
    {
#if UNITY_IOS
        // iOS ATT 対応
        var status = ATTrackingStatusBinding.GetAuthorizationTrackingStatus();
        switch (status)
        {
            case ATTrackingStatusBinding.AuthorizationTrackingStatus.NOT_DETERMINED:
                // ATT 許可依頼ダイアログを表示
                ATTrackingStatusBinding.RequestAuthorizationTracking();
                break;

            case ATTrackingStatusBinding.AuthorizationTrackingStatus.AUTHORIZED:
                //TODO: トラッキングが許可された場合の処理
                break;

            case ATTrackingStatusBinding.AuthorizationTrackingStatus.DENIED:
            case ATTrackingStatusBinding.AuthorizationTrackingStatus.RESTRICTED:
                //TODO: トラッキングが不許可・制限された場合の処理
                break;
        }
#endif
    }
}