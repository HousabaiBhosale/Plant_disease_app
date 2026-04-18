import json
from typing import Dict, List
import logging

logger = logging.getLogger(__name__)

class RecommendationService:
    def __init__(self):
        self.recommendations = {}
        self.load_recommendations()
    
    def load_recommendations(self):
        """Load recommendations from JSON file"""
        try:
            with open("data/recommendations.json", 'r') as f:
                self.recommendations = json.load(f)
            logger.info(f"Loaded {len(self.recommendations)} disease recommendations")
        except Exception as e:
            logger.error(f"Failed to load recommendations: {e}")
            self.create_default_recommendations()
    
    def create_default_recommendations(self):
        """Create default recommendations structure"""
        self.recommendations = {
            "Tomato___Late_blight": {
                "disease_name": "Late Blight",
                "plant_type": "Tomato",
                "pathogen": "Phytophthora infestans",
                "severity": "Critical",
                "symptoms": [
                    "Dark, water-soaked lesions on leaves",
                    "White fuzzy growth on underside of leaves",
                    "Brown/black spots on stems and fruit"
                ],
                "organic_treatment": [
                    "Apply copper-based fungicide every 7-10 days",
                    "Remove and destroy infected leaves immediately",
                    "Improve air circulation by pruning"
                ],
                "chemical_treatment": [
                    "Chlorothalonil-based fungicides",
                    "Mancozeb for prevention",
                    "Apply according to label instructions"
                ],
                "prevention": [
                    "Crop rotation (3-4 years)",
                    "Avoid overhead watering",
                    "Use resistant varieties",
                    "Mulch to prevent soil splash"
                ]
            },
            "Apple___Apple_scab": {
                "disease_name": "Apple Scab",
                "plant_type": "Apple",
                "pathogen": "Venturia inaequalis",
                "severity": "High",
                "symptoms": [
                    "Olive-green to black spots on leaves",
                    "Scabby lesions on fruit",
                    "Premature leaf drop"
                ],
                "organic_treatment": [
                    "Apply sulfur-based fungicides",
                    "Remove fallen leaves and infected fruit",
                    "Prune for better air circulation"
                ],
                "chemical_treatment": [
                    "Myclobutanil",
                    "Fenbuconazole",
                    "Captan"
                ],
                "prevention": [
                    "Plant resistant varieties",
                    "Clean up leaf litter in fall",
                    "Apply dormant oil in spring"
                ]
            }
            # Add all 38 diseases here...
        }
    
    def get_recommendations(self, disease_name: str) -> Dict:
        """Get recommendations for a disease"""
        if disease_name in self.recommendations:
            return self.recommendations[disease_name]
        
        # Parse disease name for fallback
        if "___" in disease_name:
            plant, disease = disease_name.split("___")
            display_name = disease.replace("_", " ")
        else:
            display_name = disease_name.replace("_", " ")
        
        return {
            "disease_name": display_name,
            "message": "Detailed treatment recommendations are being prepared for this disease.",
            "general_advice": "Please consult a local agricultural expert for specific treatment options.",
            "symptoms": ["Observe the plant carefully", "Look for spots, discoloration, or wilting"],
            "prevention": ["Maintain good air circulation", "Avoid overhead watering", "Remove infected plant parts"]
        }

recommendation_service = RecommendationService()
