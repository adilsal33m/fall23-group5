import RealityKit

enum PlacementState
{
	case idle
	case placing(ModelEntity)
	case confirming(ModelEntity)
	case inputDetails(ModelEntity, SlotsViewModel)
}
