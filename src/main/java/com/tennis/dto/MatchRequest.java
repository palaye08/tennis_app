package com.tennis.dto;

import com.tennis.model.StatutMatch;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MatchRequest {

    @NotBlank(message = "Le numéro du match est obligatoire")
    private String num;

    @NotNull(message = "Le nombre de sets est obligatoire")
    private Integer nombreDeSet;

    @NotNull(message = "Le statut est obligatoire")
    private StatutMatch statut;
}
