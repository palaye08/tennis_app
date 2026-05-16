package com.tennis.dto;

import com.tennis.model.StatutMatch;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MatchDto {
    // dans le matchDTO
    private Long id;
    private String num;
    private Integer nombreDeSet;
    private StatutMatch statut;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
