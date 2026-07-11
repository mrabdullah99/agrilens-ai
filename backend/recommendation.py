RECOMMENDATIONS = {
    "Healthy Leaf":
        "No nutrient deficiency detected.",
    "Nitrogen Deficiency":
        "Apply nitrogen fertilizer (e.g., Urea) according to recommended agricultural practices.",
    "Phosphorus Deficiency":
        "Apply phosphorus fertilizer such as DAP based on soil recommendations.",
    "Potassium Deficiency":
        "Apply potassium fertilizer such as Muriate of Potash (MOP).",
    "Zinc Deficiency":
        "Apply Zinc Sulfate after confirming deficiency with local recommendations.",
    "Multiple Nutrient Deficiencies":
        "Multiple nutrient deficiencies detected. A soil test is recommended before applying fertilizers.",
}


def get_recommendation(deficiency_label):
    return RECOMMENDATIONS[deficiency_label]